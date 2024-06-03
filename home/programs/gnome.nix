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
    programs.gnome-shell = {
      enable = true;
      extensions = with pkgs.gnomeExtensions; [
        { package = pop-shell; }
        { package = appindicator; }
      ];
    };
  };
}
