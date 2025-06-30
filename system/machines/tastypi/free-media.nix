{ lib, config, ... }:
let
  proxyPass = port: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
in {
  services.flood = {
    enable = true;
    host = "192.168.0.134";
    openFirewall = true;
  };

  services.qbittorrent = {
    enable = true;
    port = 39403;
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
        writeable = "yes";
        # allow read-only guest access
        "guest ok" = "yes";
        "read list" = "guest nobody";
        "create mask" = "0644";
        "directory mask" = "0755";
      };
    };
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # subtitles
  services.bazarr = {
    enable = true;
    openFirewall = true;
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  services.nginx.virtualHosts = {
    "media.itsvic.dev" = proxyPass 8096;

    "sonarr.media.itsvic.dev" =
      proxyPass config.services.sonarr.settings.server.port;
    "radarr.media.itsvic.dev" =
      proxyPass config.services.radarr.settings.server.port;
    "prowlarr.media.itsvic.dev" =
      proxyPass config.services.prowlarr.settings.server.port;
    "bazarr.media.itsvic.dev" = proxyPass config.services.bazarr.listenPort;
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
