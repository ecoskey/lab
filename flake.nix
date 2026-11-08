{
  description = "Homelab NixOS Configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # For some things that need the absolute latest version
    nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    authentik.url = "github:nix-community/authentik-nix";
    agenix.url = "github:ryantm/agenix";
    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      # inputs.nixpkgs.follows = "nixpkgs_unstable";
    };
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

    mkSystem = host: nixpkgs.lib.nixosSystem {
      inherit system pkgs;
      modules = [ ./${host}/configuration.nix ];
      specialArgs = { inherit inputs pkgs_unstable; };
    };
  in {
    nixosConfigurations = {
      moon = mkSystem "moon";
      pebbles = mkSystem "pebbles";
    };

    devShells.${system} = {
      default = pkgs.mkShellNoCC {
        QEMU_NET_OPTS = "hostfwd=tcp::2221-:22";
        packages = [
          agenix.packages.${system}.default
          pkgs.nixos-anywhere
          pkgs.just
        ];
      };
    };
  };
}
