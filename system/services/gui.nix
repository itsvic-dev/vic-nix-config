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
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services = {
          xserver.enable = true;
          libinput.enable = true;

          # needed for some file management stuff
          gvfs.enable = true;
        };

        # makes gstreamer work properly
        environment.sessionVariables.GST_PLUGIN_SYSTEM_PATH_1_0 =
          lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0"
            [
              pkgs.gst_all_1.gst-plugins-good
              pkgs.gst_all_1.gst-plugins-bad
              pkgs.gst_all_1.gst-plugins-ugly
            ];
      }
      (lib.mkIf (cfg.environment == "gnome") {
        services.displayManager.gdm.enable = true;
        services.xserver.desktopManager.gnome.enable = true;
      })
    ]
  );
}
