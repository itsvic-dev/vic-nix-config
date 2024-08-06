{
  imports = [
    ./hardware.nix
    ./disks.nix
  ];

  vic-nix = {
    tmpfsAsRoot = true;
    desktop.enable = true;
    hardware = {
      intel = true;
      hasEFI = false;
    };
  };
}
