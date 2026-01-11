{ intranet, config, ... }:
{
  imports = [ (intranet.nginxCertFor "media.vic") ];

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "pl-waw01";
        "netbios name" = "pl-waw01";
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
        path = "/mnt/data/torrents";
        browseable = "yes";
        writeable = "yes";
        # allow read-only guest access
        "guest ok" = "yes";
        "read list" = "guest nobody";
        "create mask" = "0644";
        "directory mask" = "0755";
      };

      media = {
        path = "/mnt/data/media";
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

  services.nfs.server = {
    enable = true;
    exports = ''
      /mnt/data     10.21.0.0/24(rw,insecure)
    '';
    hostName = "10.21.0.4";
    lockdPort = 4001;
    mountdPort = 4002;
    statdPort = 4000;
  };

  networking.firewall = {
    allowedTCPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
    allowedUDPPorts = [
      111
      2049
      4000
      4001
      4002
      20048
    ];
  };

  # create folders
  systemd.tmpfiles.rules = [
    "d '/mnt/data/torrents' 0777 nobody nogroup -"
    "d '/mnt/data/media' 0777 nobody nogroup -"
  ];

  # not sure if this would cause any security issues at least in my setup
  # but it fixes files not being properly hardlinked by sonarr/radarr
  boot.kernel.sysctl."fs.protected_hardlinks" = false;

  services.jellyfin = {
    enable = true;
  };

  services.nginx.virtualHosts = {
    "media.vic" = {
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString 8096}";
        proxyWebsockets = true;
      };
    };
  };
}
