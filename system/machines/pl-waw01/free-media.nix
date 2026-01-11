{
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
}
