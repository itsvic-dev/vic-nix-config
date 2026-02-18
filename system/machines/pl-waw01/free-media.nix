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

        "vfs objects" = "catia fruit streams_xattr";
        "fruit:metadata" = "stream";
        "fruit:model" = "MacSamba";
        "fruit:veto_appledouble" = "no";
        "fruit:nfs_aces" = "no";
        "fruit:wipe_intentionally_left_blank_rfork" = "yes";
        "fruit:delete_empty_adfiles" = "yes";
        "fruit:posix_rename" = "yes";
        "fruit:resource" = "xattr";
        "fruit:encoding" = "native";

        # some stuff i stole from reddit
        "read raw" = "yes";
        "write raw" = "yes";
        "min receivefile size" = "16384";
        "use sendfile" = "true";
        "aio read size" = "16384";
        "aio write size" = "16384";
        "strict sync" = "no";
        "sync always" = "no";
      };

      storage = {
        path = "/mnt/data/storage";
        browseable = "yes";
        writeable = "yes";
        "guest ok" = "no";
        "valid users" = "vic";
        "fruit:time machine" = "yes";
        "kernel oplocks" = "no";
        "kernel share modes" = "no";
        "posix locking" = "no";
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
    "d '/mnt/data/storage' 0755 vic users -"
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

  fileSystems."/mnt/torrents" = {
    device = "192.168.254.2:/srv/vic/Downloads";
    fsType = "nfs";
    options = [
      "nfsvers=4.2"
      "noauto"
      "noatime"
    ];
  };

  boot.supportedFilesystems = [ "nfs" ];
}
