{ config, ... }:
let
  isDesktop = config.vic-nix.desktop.enable;
in
{
  boot.loader.systemd-boot = {
    enable = true;
    # enable the editor only on desktops (devices with weaker security by design)
    editor = isDesktop;
  };
}
