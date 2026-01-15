{
  pkgs,
  lib,
  inputs,
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

  fileSystems."/mnt/data" = {
    device = "10.21.0.4:/mnt/data";
    options = [
      "nfsvers=4.2"
      "x-systemd.automount"
      "noauto"
      "noatime"
    ];
  };

  boot.supportedFilesystems = [ "nfs" ];

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
      root = "/mnt/data/torrents";
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
      root = "/mnt/data/torrents";
      extraConfig = ''
        autoindex on;
        fancyindex on;
        fancyindex_exact_size off;
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 5605 ];

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };

  # subtitles
  services.bazarr = {
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
    "request.media.itsvic.dev" = proxyPass config.services.jellyseerr.port;

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

  systemd.services.pkg-db-refresh = {
    serviceConfig = {
      Type = "oneshot";
      WorkingDirectory = "/mnt/data/torrents";
      User = "root";
    };

    script = ''
      exec ${lib.getExe pkgs.python3} ${inputs.ps4-pkg-db}/main.py http://192.168.0.134:5605
    '';
  };

  systemd.timers.pkg-db-refresh = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "15m";
      OnUnitActiveSec = "15m";
      Unit = "pkg-db-refresh.service";
    };
  };
}
