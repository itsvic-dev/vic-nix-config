{ osConfig, lib, pkgs, ... }:
let cfg = osConfig.vic-nix.desktop;
in {
  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    gtk = {
      enable = true;

      cursorTheme = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };

      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };
    };
  };
}
