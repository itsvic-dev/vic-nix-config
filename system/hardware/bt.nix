{ config, lib, ... }:
{
  config = lib.mkIf config.vic-nix.hardware.bluetooth {
    hardware.bluetooth = {
      enable = true;
      settings.General.Experimental = true;
    };
  };
}
