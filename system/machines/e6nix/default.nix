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
      docker = true;
      via = true;

      extraPackages = with pkgs; [ cider-2 ];
    };
  };

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  services = {
    jellyfin.enable = true;
    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
