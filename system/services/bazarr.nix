{ config, lib, ... }:
{
  config = lib.mkIf config.services.bazarr.enable (
    lib.mkMerge [
      # add bazarr's data dir to persistence if needed
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [
          {
            directory = "/var/lib/bazarr";
            user = config.services.bazarr.user;
            group = config.services.bazarr.group;
            mode = "0700";
          }
        ];
      })
    ]
  );
}
