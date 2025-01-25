{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.vic-nix;
in
{
  config = lib.mkIf cfg.software.solaar {
    environment.systemPackages = with pkgs; [ solaar ];
    services.udev.packages = with pkgs; [ logitech-udev-rules ];
  };
}
