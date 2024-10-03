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
  config = lib.mkIf (cfg.enable && cfg.environment == "gnome") {
    programs.gnome-shell = {
      enable = true;
      extensions = with pkgs.gnomeExtensions; [ { package = appindicator; } ];
    };
  };
}
