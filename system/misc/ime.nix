{ config, lib, pkgs, ... }:
let cfg = config.vic-nix.desktop;
in {
  config = lib.mkIf cfg.enable {
    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [ mozc uniemoji ];
    };
  };
}
