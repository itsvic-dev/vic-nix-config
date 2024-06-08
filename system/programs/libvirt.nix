{ config, lib, ... }:
let
  cfg = config.vic-nix.software;
in
{
  config = lib.mkIf cfg.libvirt {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = cfg.desktop.enable;

    users.users.vic.extraGroups = [ "libvirtd" ];
  };
}
