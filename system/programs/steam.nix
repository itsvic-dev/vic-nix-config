{ config, lib, ... }:
let
  cfg = config.vic-nix.desktop;
in
{
  config = lib.mkIf cfg.enable { programs.steam.enable = cfg.forGaming; };
}
