{
  description = "Homelab NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # For some things that need the absolute latest version
    nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    authentik.url = "github:nix-community/authentik-nix";
    agenix.url = "github:ryantm/agenix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs_unstable,
    authentik,
    agenix,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs_unstable = import nixpkgs_unstable {
      inherit system;
      config.allowUnfree = true;
    };

    # Create a VM app from a nixos config
    mkVM = name: {
      type = "app";
      program = "${self.nixosConfigurations.${name}.config.system.build.vm}/bin/run-${name}-vm";
    };
  in {
    nixosConfigurations.moon = nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [ ./moon/configuration.nix ];
      specialArgs = { inherit inputs pkgs_unstable; };
    };

    apps = {
      moon_vm = mkVM "moon";
    };

    devShells.${system} = {
      default = pkgs.mkShellNoCC {
        QEMU_NET_OPTS = "hostfwd=tcp::2221-:22";
        NIX_SSHOPTS = "-i ~/.ssh/lab_key";
        packages = [ 
          agenix.packages.${system}.default
          pkgs.nixos-anywhere
        ];
      };
    };
  };
}
