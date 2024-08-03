{
  nixosConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.vic-nix.desktop;
in
{
  config = lib.mkIf cfg.enable {
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
