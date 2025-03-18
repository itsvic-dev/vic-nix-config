{ pkgs, config, lib, ... }:
let cfg = config.vic-nix;
in {
  config = lib.mkIf cfg.software.libvirt (lib.mkMerge [
    {
      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
        qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
      };

      virtualisation.spiceUSBRedirection.enable = true;
      programs.virt-manager.enable = cfg.desktop.enable;

      users.users.vic.extraGroups = [ "libvirtd" ];
    }
    (lib.mkIf cfg.tmpfsAsRoot {
      environment.persistence."/persist".directories = [ "/var/lib/libvirt" ];
    })
  ]);
}
