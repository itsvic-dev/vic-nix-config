{ lib, config, pkgs, ... }:
let cfg = config.vic-nix.desktop;
in {
  config = lib.mkIf cfg.enable { programs.gnupg.agent = { enable = true; }; };
}
