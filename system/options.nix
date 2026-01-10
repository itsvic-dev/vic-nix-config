{ lib, pkgs, ... }:
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

      autoUpdate = mkOption {
        type = types.bool;
        default = false; # FIXME
        description = "Whether the machine should auto-update based on system builds from hydra.vic.";
      };

      noSecrets = mkOption {
        type = types.bool;
        default = false;
        description = "Whether sops-nix secrets should be skipped for bootstrapping.";
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
        docker = mkEnableOption "Docker";
        via = mkEnableOption "VIA";
        solaar = mkEnableOption "Solaar";

        extraPackages = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = "Extra packages to install in Home Manager.";
        };
      };

      desktop = {
        enable = mkEnableOption "the desktop role";

        environment = mkOption {
          type = types.enum [
            "gnome"
            "osx"
          ];
          default = if pkgs.stdenv.isLinux then "gnome" else "osx";
          description = "The desktop environment to use.";
        };

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
