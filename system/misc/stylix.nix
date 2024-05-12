{ pkgs, ... }:
{
  stylix = {
    image = ../wallpaper.jpg;
    polarity = "dark";
    cursor = {
      package = pkgs.gnome.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    fonts = {
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
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
  };
}
