{ config, pkgs, pkgs_unstable, inputs, ... }:
{
  imports = [
    inputs.authentik.nixosModules.default
    inputs.disko.nixosModules.default

    ../base/system.nix
    ./hardware-configuration.nix
    ./disk-config.nix
  ];

  networking.hostName = "moon";

  age.secrets = {
    authentik_env.file = ./secrets/authentik_env.age;
    caddy_env.file = ./secrets/caddy_env.age;
    cf_api_token.file = ./secrets/cf_api_token.age;
  };

  services = {
    ddclient = {
      enable = true;
      interval = "5min";
      protocol = "cloudflare";
      username = "token";
      passwordFile = config.age.secrets.cf_api_token.path;
      domains = [ "*.lupine.computer" ];
      zone = "lupine.computer";
      ssl = true;
    };

    avahi = {
      enable = true;
      publish = {
        enable = true;
        addresses = true;
      };
    };

    caddy = {
      enable = true;
      openFirewall = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.4" ];
        hash = "sha256-xRJ5evsAJ2akg47j3Bt6YDXJOgX88B/rKNP50KSVyNY=";
      };
      environmentFile = config.age.secrets.caddy_env.path;
      virtualHosts = {
        "*.lupine.computer".extraConfig = ''
          tls {
            dns cloudflare {env.CF_API_TOKEN}
            resolvers 1.1.1.1
          }

          @home host home.lupine.computer
          @auth host auth.lupine.computer
          @git host git.lupine.computer

          reverse_proxy @home http://10.0.3.3
          reverse_proxy @auth http://127.0.0.1:9000
          reverse_proxy @git http://127.0.0.1:3000 {
            header_up X-Real-IP {remote_host}
          }
        '';
      };
    };

    authentik = {
      enable = true;
      # The environmentFile needs to be on the target host!
      # Best use something like sops-nix or agenix to manage it
      environmentFile = config.age.secrets.authentik_env.path;
      settings = {
        # email = {
        #   host = "smtp.example.com";
        #   port = 587;
        #   username = "authentik@example.com";
        #   use_tls = true;
        #   use_ssl = false;
        #   from = "authentik@example.com";
        # };
        disable_startup_analytics = true;
        avatars = "initials";
      };
    };

    forgejo = {
      enable = true;
      database.type = "postgres";
      # Enable support for Git Large File Storage
      lfs.enable = true;
      settings = {
        server = {
          DOMAIN = "git.lupine.computer";
          # You need to specify this to remove the port from URLs in the web UI.
          ROOT_URL = "https://git.lupine.computer/"; 
          HTTP_PORT = 3000;
        };

        oauth2_client = {
          ENABLE_AUTO_REGISTRATION = true;
        };

        # You can temporarily allow registration to create an admin user.
        service.DISABLE_REGISTRATION = true;
        # Add support for actions, based on act: https://github.com/nektos/act
        actions = {
          ENABLED = true;
          DEFAULT_ACTIONS_URL = "github";
        };
      };
    };
  };

  # DO NOT EDIT !!!
  system.stateVersion = "26.05";
}
