{ lib, ... }: {
  services.flood = {
    enable = true;
    host = "192.168.0.134";
    openFirewall = true;
  };

  services.rtorrent = {
    enable = true;
    downloadDir = "/var/torrents";
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "tastypi";
        "netbios name" = "tastypi";
        security = "user";
        "hosts allow" = "192.168.0. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };

      torrents = {
        path = "/var/torrents";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };

      media = {
        path = "/var/media";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      flaresolverr = {
        image = "ghcr.io/flaresolverr/flaresolverr:latest";
        ports = [ "8191:8191" ];
      };
    };
  };

  # create folders
  systemd.tmpfiles.rules = [
    "d '/var/torrents' 0777 nobody nogroup -"
    "d '/var/media' 0777 nobody nogroup -"
  ];
}
