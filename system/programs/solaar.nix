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
    environment.systemPackages = with pkgs; [
      logitech-udev-rules
      solaar
    ];
  };
}
