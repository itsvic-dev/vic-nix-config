{
  config,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    #./ptero.nix
    #./remote-builders.nix
    ./hardware.nix
    ./disks.nix
  ];

  vic-nix = {
    tmpfsAsRoot = true;
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
      libvirt = false;
      timidity = false;
    };
  };

  services.wings = {
    enable = false;
    openFirewall = false;
  };

  networking.firewall.allowedTCPPorts = [
    3000 # nuxt dev projects
  ];
}
