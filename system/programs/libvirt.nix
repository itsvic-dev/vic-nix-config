{ config, lib, ... }:
let
  cfg = config.vic-nix;
in
{
  config = lib.mkIf cfg.modules.libvirt {
    virtualisation.libvirtd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;
    programs.virt-manager.enable = cfg.desktop.enable;

    users.users.vic.extraGroups = [ "libvirtd" ];
  };
}
