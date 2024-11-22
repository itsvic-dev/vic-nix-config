{ config, lib, ... }:
{
  config = lib.mkIf config.services.transmission.enable (
    lib.mkMerge [
      # add transmission's data dir to persistence if needed
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [
          {
            directory = config.services.transmission.home;
            user = config.services.transmission.user;
            group = config.services.transmission.group;
            mode = "0700";
          }
        ];
      })
    ]
  );
}
