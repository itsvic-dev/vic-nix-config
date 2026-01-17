{
  intranet,
  ...
}:
{
  imports = [
    ./bird.nix
    ./bind
    ./registry.nix
    ./acme.nix
    intranet.sysctls
    intranet.transfers
    intranet.dummy
  ];

  sops.secrets.vic-net-sk = { };
  networking.firewall.allowedUDPPorts = [ 6696 ];

  services.nginx.virtualHosts."vic.iw" = {
    enableACME = true;
    forceSSL = true;
    listenAddresses = [ "10.21.0.1" ];
    globalRedirect = "www.vic.iw";
  };

  services.nginx.virtualHosts."www.vic.iw" = {
    useACMEHost = "vic.iw";
    forceSSL = true;
    listenAddresses = [ "10.21.0.1" ];
    root = ./vic-iw;
  };

  security.acme.certs."vic.iw" = {
    server = "https://acme.iw/acme/directory";
    extraDomainNames = [ "www.vic.iw" ];
  };
}
