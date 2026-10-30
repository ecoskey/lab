let
  system = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhZPaGoMdsFWKJAOtFm6YnPRv5dg1sdbiMgZxdma9+S emerson@wolfshirt";
in {
  "passwd_emerson.age".publicKeys = [ system ];
}
