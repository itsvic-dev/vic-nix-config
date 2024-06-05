{ config, lib, ... }:
let
  cfg = config.vic-nix.desktop;
in
{
  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    services.libinput.enable = true;

    # needed for some file management stuff, gnome prob enables it already but still
    services.gvfs.enable = true;
  };
}
