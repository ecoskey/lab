let
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhZPaGoMdsFWKJAOtFm6YnPRv5dg1sdbiMgZxdma9+S";
in {
  "authentik_env.age".publicKeys = [ system ];
  "caddy_env.age".publicKeys = [ system ];
  "cf_api_token.age".publicKeys = [ system ];
  "forgejo_env.age".publicKeys = [ system ];
}
