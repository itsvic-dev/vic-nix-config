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
    programs.kitty = {
      enable = true;
      settings = {
        window_padding_width = 8;
      };
    };
  };
}
