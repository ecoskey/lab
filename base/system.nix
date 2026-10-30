{ config, pkgs, pkgs_unstable, inputs, ... }:
{
  imports = [ inputs.agenix.nixosModules.default ];

  # add caches
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # auto-optimize store every week
  nix.optimise = {
    automatic = true;
    dates = ["weekly"];
  };

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      # Use the systemd-boot EFI boot loader.
      systemd-boot = {
        enable = true;
        configurationLimit = 20;
      };
    };

    zfs.forceImportRoot = false;

    # Use latest kernel.
    kernelPackages = pkgs.linuxPackages;
  };

  virtualisation.vmVariant = {
    # following configuration is added only when building VM with build-vm
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 2;
      graphics = false;
    };

    # WARN: USING STORE PATHS HERE IS INSECURE AND FOR TEST VM USE ONLY
    environment.etc = {
      "ssh/ssh_host_ed25519_key" = {
        source = ../extra_files/etc/ssh/ssh_host_ed25519_key;
        mode = "0600";
        user = "root";
        group = "root";
      };
      "ssh/ssh_host_ed25519_key.pub" = {
        source = ../extra_files/etc/ssh/ssh_host_ed25519_key.pub;
        mode = "0644";
        user = "root";
        group = "root";
      };
      "ssh/ssh_host_rsa_key" = {
        source = ../extra_files/etc/ssh/ssh_host_rsa_key;
        mode = "0600";
        user = "root";
        group = "root";
      };
      "ssh/ssh_host_rsa_key.pub" = {
        source = ../extra_files/etc/ssh/ssh_host_rsa_key.pub;
        mode = "0644";
        user = "root";
        group = "root";
      };
    };

    # WARN: USING STORE PATHS HERE IS INSECURE AND FOR TEST VM USE ONLY
    age.identityPaths = [ 
      ../extra_files/etc/ssh/ssh_host_ed25519_key
      ../extra_files/etc/ssh/ssh_host_rsa_key
    ];
  };

  # Set time zone.
  time.timeZone = "America/Los_Angeles";

  # Set internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  age.secrets = {
    passwd_emerson.file = ./secrets/passwd_emerson.age;
  };

  # Define my user account. Hosts can add extra groups as needed
  users.users."emerson" = {
    isNormalUser = true;
    description = "Emerson";
    extraGroups = [ "wheel" ];
    hashedPasswordFile = config.age.secrets.passwd_emerson.path;
    openssh.authorizedKeys.keys = [ (builtins.readFile ./secrets/lab_key.pub) ];
  };

  users.users."root" = {
    hashedPasswordFile = config.age.secrets.passwd_emerson.path;
    openssh.authorizedKeys.keys = [ (builtins.readFile ./secrets/lab_key.pub) ];
  };

  # Basic packages I want in every environment
  environment.systemPackages = with pkgs; [
    neovim
    wget
    git
    btop
  ];

  services = {
    # power-profiles-daemon.enable = true;
    # upower.enable = true;
    udisks2.enable = true;

    openssh = {
      enable = true;
      ports = [ 22 ];
      generateHostKeys = false;
      settings = {
        PasswordAuthentication = true;
        AllowUsers = [ "root" "emerson" ]; # Allows all users by default. Can be [ "user1" "user2" ]
        X11Forwarding = false;
        PermitRootLogin = "yes"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
      };
    };
  };

  # DO NOT EDIT !!!
  system.stateVersion = "26.05";
}
