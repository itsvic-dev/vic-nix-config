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

  # create /var/media folder
  systemd.tmpfiles.rules = [ "d '/var/media' 0777 nobody nogroup -" ];
}
