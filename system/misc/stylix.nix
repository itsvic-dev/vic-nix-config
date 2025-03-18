{ pkgs, config, ... }: {
  stylix = {
    enable = config.vic-nix.desktop.enable;
    image = ../wallpaper.jpg;
    base16Scheme = ../scheme.yaml;
    polarity = "dark";

    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    fonts = {
      sansSerif = {
        package = pkgs.adwaita-fonts;
        name = "Adwaita Sans";
      };

      serif = {
        package = pkgs.noto-fonts;
        name = "Noto Serif";
      };

      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrains Mono";
      };

      sizes = {
        applications = 10;
        terminal = 10;
      };
    };

    # system-wide target settings
    targets = {
      chromium.enable = false;
      qt.enable = false;
    };
  };
}
