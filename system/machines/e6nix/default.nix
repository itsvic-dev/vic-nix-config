{ config, lib, pkgs, ... }: {
  imports = [
    #./ptero.nix
    ./remote-builders.nix
    ./hardware.nix
    ./disks.nix
    ./jellyfin.nix
    ./restic.nix
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
      solaar = true;

      extraPackages = with pkgs; [ cider-2 android-studio ];
    };
  };

  boot.kernelParams = [ "nouveau.config=NvGspRm=1" ];

  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  services = {
    pcscd.enable = true;
    ollama.enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
