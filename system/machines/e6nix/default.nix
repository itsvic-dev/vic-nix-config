{
  config,
  modulesPath,
  lib,
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
    };
  };

  programs.kdeconnect.enable = true;
  virtualisation.docker.enable = true;

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  services.wings = {
    enable = false;
    openFirewall = false;
  };

  networking.firewall.allowedTCPPorts = [
    3000 # nuxt dev projects
  ];
}
