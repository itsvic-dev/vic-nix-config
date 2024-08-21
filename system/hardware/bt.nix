{ config, lib, ... }:
{
  config = lib.mkIf config.vic-nix.hardware.bluetooth (
    lib.mkMerge [
      {
        hardware.bluetooth = {
          enable = true;
          settings.General.Experimental = true;
        };
      }
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [ "/var/lib/bluetooth" ];
      })
    ]
  );
}
