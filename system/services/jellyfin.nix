{ config, lib, ... }:
{
  config = lib.mkIf config.services.jellyfin.enable (
    lib.mkMerge [
      # add jellyfin to the render group
      { users.users.jellyfin.extraGroups = [ "render" ]; }

      # add jellyfin's data dir to persistence if needed
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [ config.services.jellyfin.dataDir ];
      })
    ]
  );
}
