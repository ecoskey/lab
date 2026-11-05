{ config, lib, pkgs, pkgs_unstable, inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.default
    ../base/configuration.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hostName = "pebbles";

  hardware.graphics.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.open = true;  # see the note above

  # User for steamos autologin. Not a member of @wheel
  users.users."gamer" = { };

  services = {
    avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    xserver.enable = false;
    getty.autologinUser = "gamer";
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${lib.getExe pkgs.gamescope} -W 3840 -H 2160 -f -e --xwayland-count 2 --hdr-enabled --hdr-itm-enabled -- steam -pipewire-dmabuf -gamepadui -steamdeck -steamos3 > /dev/null 2>&1";
          user = "gamer";
        };
      };
    };
  };

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
    };
  };

  # DO NOT EDIT !!!
  system.stateVersion = "26.05";
}
