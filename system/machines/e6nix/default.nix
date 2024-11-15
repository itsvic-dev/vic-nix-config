{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    #./ptero.nix
    ./remote-builders.nix
    ./hardware.nix
    ./disks.nix
  ];

  vic-nix = {
    tmpfsAsRoot = true;
    secureBoot = true;

    desktop = {
      enable = true;
      forGaming = true;
      forDev = true;
    };

    hardware = {
      intel = true;
      nvidia = true;
      bluetooth = true;
    };

    software = {
      libvirt = true;
      timidity = false;
      docker = true;
    };
  };

  home-manager.users.vic.home.packages = with pkgs; [ cider-2 ];

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # udev rule to allow read/write access to Keychron HID devices
  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3434", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
