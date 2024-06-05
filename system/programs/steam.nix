{ config, lib, ... }:
let
  cfg = config.vic-nix.desktop;
in
{
  config = lib.mkIf (cfg.enable && cfg.forGaming) { programs.steam.enable = true; };
}
