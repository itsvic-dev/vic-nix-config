{ config, lib, ... }: {
  config = lib.mkIf config.services.jellyfin.enable (lib.mkMerge [
    # add jellyfin to the render group
    {
      users.users.jellyfin.extraGroups = [ "render" ];
    }

    # add jellyfin's data dir to persistence if needed
    (lib.mkIf config.vic-nix.tmpfsAsRoot {
      environment.persistence."/persist".directories = [{
        directory = config.services.jellyfin.dataDir;
        user = config.services.jellyfin.user;
        group = config.services.jellyfin.group;
        mode = "0700";
      }];
    })
  ]);
}
