{ config, lib, ... }:
let
  cfg = config.vic-nix.desktop;
in
{
  config = lib.mkIf (cfg.enable && cfg.forDev) {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = true;
  };
}
