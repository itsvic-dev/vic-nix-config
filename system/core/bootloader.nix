{
  config,
  inputs,
  pkgs,
  ...
}:
let
  isDesktop = config.vic-nix.desktop.enable;
in
{
  imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

  boot.loader.systemd-boot = {
    enable = config.vic-nix.hardware.hasEFI && !config.vic-nix.secureBoot;
    # enable the editor only on desktops (devices with weaker security by design)
    editor = isDesktop;
  };

  boot.lanzaboote = {
    enable = config.vic-nix.secureBoot;
    pkiBundle = if config.vic-nix.tmpfsAsRoot then "/persist/etc/secureboot" else "/etc/secureboot";
  };

  boot.loader.grub = {
    enable = !config.vic-nix.hardware.hasEFI && pkgs.stdenv.hostPlatform.isx86;
  };
}
