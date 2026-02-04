{ lib, ... }:
{
  networking.firewall.allowedUDPPorts = [ 53 ];
  services.bind = {
    enable = true;
    listenOn = [ "10.21.0.3" ];
    cacheNetworks = [ "10.0.0.0/8" ];
    forwarders = lib.mkForce [ "10.21.0.1" ];
    forward = "only";
    extraOptions = ''
      dnssec-validation no;
    '';
  };
}
