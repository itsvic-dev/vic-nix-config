{ config, lib, ... }:
{
  config = lib.mkIf config.services.radarr.enable (
    lib.mkMerge [
      # add radarr's data dir to persistence if needed
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [
          {
            directory = config.services.radarr.dataDir;
            user = config.services.radarr.user;
            group = config.services.radarr.group;
            mode = "0700";
          }
        ];
      })
    ]
  );
}
