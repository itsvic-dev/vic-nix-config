{
  config,
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    ./ptero.nix
    ./remote-builders.nix
    ./hardware.nix
  ];

  vic-nix = {
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
      timidity = true;
    };
  };

  services.wings = {
    enable = true;
    openFirewall = false;
  };

  services.ollama.enable = true;

  networking.firewall.allowedTCPPorts = [
    3000 # nuxt dev projects
  ];
}
