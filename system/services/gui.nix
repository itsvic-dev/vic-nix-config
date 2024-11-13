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
        services.xserver = {
          displayManager.gdm.enable = true;
          desktopManager.gnome = {
            enable = true;
            extraGSettingsOverridePackages = [ pkgs.mutter ];
            extraGSettingsOverrides = ''
              [org.gnome.mutter]
              experimental-features=['scale-monitor-framebuffer']
            '';
          };
        };

        environment.gnome.excludePackages = with pkgs; [
          epiphany
          geary
          totem # Videos
          gnome-music
        ];
      })
    ]
  );
}
