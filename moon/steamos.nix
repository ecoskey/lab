{ config, pkgs, pkgs_unstable, inputs, ... }:
{
  imports = [ inputs.jovian.nixosModules.default ];

  hardware = {
    graphics.enable = true;
    nvidia.open = true;
    xone.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  # User for steamos autologin. Not a member of @wheel
  users.users."steamuser" = {
    isNormalUser = true;
  };

  networking.networkmanager.enable = true;

  services = {
    xserver.videoDrivers = [ "nvidia" ];
    desktopManager.plasma6.enable = true;
    # disable display manager for Plasma
    displayManager.plasma-login-manager.enable = false;
  };

  jovian = {
    steam = {
      user = "steamuser";
      enable = true;
      autoStart = true;
      desktopSession = "plasma";
    };
  };

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
    };
  };

  programs.steam = {
    enable = true;
  };
}
