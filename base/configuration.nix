{ config, lib, pkgs, pkgs_unstable, inputs, ... }:
{
  imports = [ inputs.agenix.nixosModules.default ];

  # add caches
  nix.settings = {
    trusted-users = [ "@wheel" ];
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

  users = {
    groups."local_ssh" = { };

    # Define my user account. Hosts can add extra groups as needed
    users."emerson" = {
      isNormalUser = true;
      description = "Emerson";
      extraGroups = [ "wheel" "local_ssh" ];
      hashedPasswordFile = "${./emerson_passwd}";
      openssh.authorizedKeys.keys = [ (builtins.readFile ./lab_key.pub) ];
    };
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
        PasswordAuthentication = false;
        # AllowGroups = [ "local_ssh@10.0.0.0/8" ];
        AllowUsers = [ "emerson" ];
        DisableForwarding = true;
        PermitRootLogin = "no";
      };
    };
  };
}
