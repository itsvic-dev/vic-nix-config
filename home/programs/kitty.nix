{ osConfig, lib, pkgs, ... }:
let cfg = osConfig.vic-nix.desktop;
in {
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        window_padding_width = 8;
        remember_window_size = false;
        initial_window_width = "80c";
        initial_window_height = "25c";
      };
    };
  };
}
