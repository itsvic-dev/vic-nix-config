{
  config,
  pkgs,
  inputs,
  ...
}:
{
  home.packages = [
    pkgs.kitty
    pkgs.pcmanfm-qt
  ];

  programs.tofi = {
    enable = true;
    settings = {
      width = "100%";
      height = "100%";
      border-width = 0;
      outline-width = 0;
      padding-left = "35%";
      padding-top = "35%";
      result-spacing = 25;
      num-results = 5;
      font = "monospace";
      background-color = "#000A";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = inputs.hyprland.packages."${pkgs.system}".hyprland;

    settings = {
      general = {
        gaps_in = 10;
        gaps_out = 20;
        border_size = 2;
        "col.active_border" = "rgba(89b4faee)";
        "col.inactive_border" = "rgba(585b70aa)";

        layout = "dwindle";
        allow_tearing = false;
      };

      dwindle = {
        preserve_split = true;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 8;
          passes = 4;
        };

        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;

        bezier = [ "outExpo, 0.16, 1, 0.3, 1" ];

        animation = [
          "global, 1, 7, outExpo"
          "windowsOut, 1, 7, outExpo, popin 80%"
          "specialWorkspace, 1, 7, outExpo, slidefadevert 50%"
        ];
      };

      "$mod" = "SUPER";

      bind =
        [
          ", Print, exec, ${pkgs.grimblast}/bin/grimblast copy output"
          "Ctrl, Print, exec, ${pkgs.grimblast}/bin/grimblast -f copy area"

          "$mod, Q, exec, kitty"
          "$mod, C, killactive"
          "$mod, M, exit"
          "$mod, E, exec, ${pkgs.pcmanfm-qt}/bin/pcmanfm-qt"
          "$mod, V, togglefloating"
          "$mod, R, exec, ${pkgs.tofi}/bin/tofi-drun --drun-launch=true"
          "$mod, J, togglesplit"

          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          "$mod, S, togglespecialworkspace, scratchpad"
          "$mod SHIFT, S, movetoworkspace, special:scratchpad"
        ]
        ++ (
          # workspaces {1..10}
          builtins.concatLists (
            builtins.genList (
              x:
              let
                ws =
                  let
                    c = (x + 1) / 10;
                  in
                  builtins.toString (x + 1 - (c * 10));
              in
              [
                "$mod, ${ws}, workspace, ${toString (x + 1)}"
                "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
              ]
            ) 10
          )
        );

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      monitor = [
        "eDP-1, 1920x1080@120, 1920x0, 1"
        "HDMI-A-1, 1920x1080@60, 0x0, 1"
      ];

      env = [
        "QT_QPA_PLATFORMTHEME, qt5ct"
        "QT_AUTO_SCREEN_SCLAE_FACTOR, 1"
        "QT_QPA_PLATFORM, wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
      ];

      exec-once = [
        "${pkgs.mako}/bin/mako"
        "${pkgs.waybar}/bin/waybar"
        "${pkgs.aria2}/bin/aria2c --enable-rpc"
        "${pkgs.fcitx5} --replace -d"
        "${pkgs.hyprpaper}/bin/hyprpaper"
      ];

      input = {
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
        touchpad.natural_scroll = true;
        tablet.output = "HDMI-A-1";
      };
    };
  };
}
