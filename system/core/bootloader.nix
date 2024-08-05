{ config, ... }:
let
  isDesktop = config.vic-nix.desktop.enable;
  inherit (config.vic-nix.hardware) hasEFI;
in
{
  config =
    if hasEFI then
      {
        boot.loader.systemd-boot = {
          enable = true;
          # enable the editor only on desktops (devices with weaker security by design)
          editor = isDesktop;
        };
      }
    else
      {
        boot.loader.grub = {
          enable = true;
        };
      };
}
