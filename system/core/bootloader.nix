{ config, ... }:
let
  isDesktop = config.vic-nix.desktop.enable;
in
{
  boot.loader.systemd-boot = {
    enable = config.vic-nix.hardware.hasEFI;
    # enable the editor only on desktops (devices with weaker security by design)
    editor = isDesktop;
  };

  boot.loader.grub = {
    enable = !config.vic-nix.hardware.hasEFI;
  };
}
