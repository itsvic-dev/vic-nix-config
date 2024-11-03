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
      nvidia = false; # broken, using nouveau instead
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
}
