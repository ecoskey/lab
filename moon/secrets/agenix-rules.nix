let
  host = builtins.readFile ../host_keys/ssh_host_ed25519_key.pub;
in {
  "authentik_env.age".publicKeys = [ host ];
  "caddy_env.age".publicKeys = [ host ];
  "cf_api_token.age".publicKeys = [ host ];
}
