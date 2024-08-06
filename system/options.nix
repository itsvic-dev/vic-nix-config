{ lib, ... }:
with lib;
{
  # Configuation schema
  options = {
    vic-nix = {
      tmpfsAsRoot = mkOption {
        type = types.bool;
        default = false;
        description = "Whether the machine uses a tmpfs-as-root partition style.";
      };

      secureBoot = mkEnableOption "UEFI Secure Boot";

      hardware = {
        intel = mkEnableOption "Intel hardware support";
        nvidia = mkEnableOption "Nvidia hardware support";
        bluetooth = mkEnableOption "Bluetooth";

        hasEFI = mkOption {
          type = types.bool;
          default = true;
          description = "Whether the machine has UEFI firmware. This is usually true.";
        };
      };

      software = {
        timidity = mkEnableOption "timidity";
        libvirt = mkEnableOption "the libvirt module";
      };

      desktop = {
        enable = mkEnableOption "the desktop role";

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

      server = {
        enable = mkEnableOption "the server role";
      };
    };
  };
}
