{ config, ... }:
{
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  networking.firewall.allowedTCPPorts = [
    3000 # Nuxt dev services
    8443 # demo panel wings
  ];
}
