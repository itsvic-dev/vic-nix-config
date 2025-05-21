{ lib, ... }: {
  services.flood = {
    enable = true;
    host = "192.168.0.134";
    openFirewall = true;
  };

  services.rtorrent = {
    enable = true;
    downloadDir = "/var/media";
  };

  # fixes crashes related to chown calls
  systemd.services.rtorrent.serviceConfig.SystemCallFilter = lib.mkForce [ ];

  # create /var/media folder
  systemd.tmpfiles.rules = [ "d '/var/media' 0777 nobody nogroup -" ];
}
