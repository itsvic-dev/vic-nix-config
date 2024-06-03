{ lib, ... }:
with lib;
{
  # Configuation schema
  options = {
    vic-nix = {
      hardware = {
        intel = mkEnableOption "Intel hardware support";
        nvidia = mkEnableOption "Nvidia hardware support";
        bluetooth = mkEnableOption "Bluetooth";
      };

      desktop = {
        enable = mkEnableOption "desktop mode";

        forGaming = mkOption {
          type = types.bool;
          default = false;
          description = "Whether the machine will be used for gaming (mainly controls Steam).";
        };

        forDev = mkOption {
          type = types.bool;
          default = false;
          description = "Whether the machine will be used as a development workspace.";
        };
      };
    };
  };
}
