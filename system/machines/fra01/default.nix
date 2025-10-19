{
  imports = [ ./disko.nix ];

  vic-nix = {
    server.enable = true;
    noSecrets = true;
  };

  users.users.root.hashedPassword =
    "$y$j9T$pa4EgdgP3jUPyu/c7Iue.1$x9as1wf3LkJKElWGhFIxBEsFXdiRBhe3aDT7GIVAl./";
}
