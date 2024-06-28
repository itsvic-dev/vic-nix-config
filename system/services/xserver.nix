{
  config,
  pkgs,
  lib,
  ...
}:
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

    # for some reason, there is no default for this on NixOS.
    environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
      lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
        [
          pkgs.gst_all_1.gst-plugins-good
          pkgs.gst_all_1.gst-plugins-bad
          pkgs.gst_all_1.gst-plugins-ugly
          pkgs.gst_all_1.gst-plugins-libav
        ];
  };
}
