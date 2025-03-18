{ config, lib, pkgs, ... }:
let cfg = config.vic-nix.desktop;
in {
  config = lib.mkIf (cfg.enable && cfg.forGaming) {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override ({ extraLibraries = p: with p; [ SDL2 ]; });
      protontricks.enable = true;
    };
  };
}
