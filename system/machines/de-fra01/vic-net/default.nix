{
  intranet,
  ...
}:
{
  imports = [
    ./bird.nix
    ./bind
    ./registry.nix
    intranet.sysctls
    intranet.transfers
    intranet.dummy
  ];

  sops.secrets.vic-net-sk = { };
  networking.firewall.allowedUDPPorts = [ 6696 ];

  services.nginx.virtualHosts."vic.iw" = {
    listenAddresses = [ "10.21.0.1" ];
    globalRedirect = "www.vic.iw";
  };

  services.nginx.virtualHosts."www.vic.iw" = {
    listenAddresses = [ "10.21.0.1" ];
    root = ./vic-iw;
  };
}
