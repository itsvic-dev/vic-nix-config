{
  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = [
    "ehci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];
}
