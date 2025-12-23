{
  pkgs,
  config,
  intranet,
  ...
}:
let
  proxyPass = port: {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
in
{
  imports = [
    (intranet.nginxCertFor "torrents.vic")
    (intranet.nginxCertFor "flood.vic")
  ];

  services.flood = {
    enable = true;
  };

  services.qbittorrent = {
    enable = true;
    webuiPort = 39403;
    openFirewall = true;
    profileDir = "/var/lib/qbittorrent";
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  services.nginx = {
    additionalModules = [ pkgs.nginxModules.fancyindex ];

    virtualHosts."flood.vic" = {
      listenAddresses = [ (intranet.ips.tastypi) ];
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.flood.port}";
        proxyWebsockets = true;
      };
    };

    # intranet-facing page
    virtualHosts."torrents.vic" = {
      listenAddresses = [ (intranet.ips.tastypi) ];
      forceSSL = true;
      root = "/var/torrents";
      extraConfig = ''
        autoindex on;
        fancyindex on;
        fancyindex_exact_size off;
      '';
    };

    # LAN-facing page
    virtualHosts."torrents-home" = {
      listen = [
        {
          addr = "192.168.0.134";
          port = 5605;
        }
      ];
      root = "/var/torrents";
      extraConfig = ''
        autoindex on;
        fancyindex on;
        fancyindex_exact_size off;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 5605 ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "tastypi";
        "netbios name" = "tastypi";
        security = "user";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "vfs objects" = "fruit streams_xattr";
        "fruit:aapl" = "yes";
        "fruit:model" = "MacSamba";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:posix_rename" = "yes";
      };

      torrents = {
        path = "/var/torrents";
        browseable = "yes";
        writeable = "yes";
        # allow read-only guest access
        "guest ok" = "yes";
        "read list" = "guest nobody";
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

  services.jellyseerr = {
    enable = true;
    openFirewall = true;
  };

  # not sure if this would cause any security issues at least in my setup
  # but it fixes files not being properly hardlinked by sonarr/radarr
  boot.kernel.sysctl."fs.protected_hardlinks" = false;

  services.nginx.virtualHosts = {
    "media.itsvic.dev" = proxyPass 8096;
    "request.media.itsvic.dev" = proxyPass config.services.jellyseerr.port;

    "sonarr.media.itsvic.dev" = proxyPass config.services.sonarr.settings.server.port;
    "radarr.media.itsvic.dev" = proxyPass config.services.radarr.settings.server.port;
    "prowlarr.media.itsvic.dev" = proxyPass config.services.prowlarr.settings.server.port;
    "bazarr.media.itsvic.dev" = proxyPass config.services.bazarr.listenPort;
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      byparr = {
        image = "ghcr.io/thephaseless/byparr:latest";
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
