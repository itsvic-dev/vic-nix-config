{ lib, config, pkgs, ... }:
let enabled = config.vic-nix.software.via;
in {
  config = lib.mkIf enabled {
    environment.systemPackages = [ pkgs.via ];

    # udev rule to allow read/write access to Keychron hidraw devices
    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    '';
  };
}
