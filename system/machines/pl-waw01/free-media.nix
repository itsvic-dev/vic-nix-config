{ config, intranet, ... }:
let
  proxyPass = port: {
    listenAddresses = [ (intranet.ips.pl-waw01) ];
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
in
{
  imports = [
    (intranet.nginxCertFor "media.vic")
    (intranet.nginxCertFor "sonarr.vic")
    (intranet.nginxCertFor "radarr.vic")
  ];

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
        path = "/mnt/torrents";
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

  # create folders
  systemd.tmpfiles.rules = [
    "d '/mnt/data/torrents' 0777 nobody nogroup -"
    "d '/mnt/data/media' 0777 nobody nogroup -"
  ];

  services.jellyfin = {
    enable = true;
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;
  };

  services.radarr = {
    enable = true;
    openFirewall = true;
  };

  services.nginx.virtualHosts = {
    "media.vic" = proxyPass 8096;
    "sonarr.vic" = proxyPass config.services.sonarr.settings.server.port;
    "radarr.vic" = proxyPass config.services.radarr.settings.server.port;
  };

  systemd.network.networks."50-ens20" = {
    matchConfig.name = "ens20";
    networkConfig = {
      Address = "192.168.254.1/30";
    };
  };

  fileSystems."/mnt/torrents" = {
    device = "192.168.254.2:/srv/vic/Downloads";
    options = [
      "nfsvers=4.2"
      "x-systemd.automount"
      "noauto"
      "noatime"
    ];
  };

  boot.supportedFilesystems = [ "nfs" ];
}
