{
  nixosConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.vic-nix;
in
{
  config = lib.mkIf (cfg.desktop.enable && cfg.desktop.environment == "gnome") (
    lib.mkMerge [
      {
        programs.gnome-shell = {
          enable = true;
          extensions = with pkgs.gnomeExtensions; [
            { package = appindicator; }
            { package = gsconnect; }
          ];
        };
      }

      (lib.mkIf cfg.software.solaar {
        programs.gnome-shell.extensions = with pkgs.gnomeExtensions; [ { package = solaar-extension; } ];
      })
    ]
  );
}
