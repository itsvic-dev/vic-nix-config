{ config, lib, ... }:
{
  config = lib.mkIf config.services.aria2.enable (
    lib.mkMerge [
      # add aria2's data dir to persistence if needed
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [
          {
            directory = "/var/lib/aria2";
            user = "aria2";
            group = "aria2";
            mode = "0740";
          }
        ];
      })
    ]
  );
}
