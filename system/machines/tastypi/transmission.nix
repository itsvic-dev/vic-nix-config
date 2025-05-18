{ pkgs, ... }: {
  services.transmission = {
    enable = true;
    openPeerPorts = true;
    openRPCPort = true;
    webHome = pkgs.flood-for-transmission;

    downloadDirPermissions = "777";
    settings = {
      umask = "000";
      rpc-whitelist = "127.0.0.1,192.168.0.*";
    };
  };
}
