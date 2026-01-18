{
  config,
  intranet,
  inputs,
  ...
}:
{
  imports = [
    ./bird.nix
    intranet.sysctls
    intranet.transfers
    intranet.dummy

    inputs.searchiw.nixosModules.default
  ];

  sops.secrets.vic-net-sk = { };
  networking.firewall.allowedUDPPorts = [ 6696 ];

  services.searchiw = {
    enable = true;
    bind = "127.0.0.1:7665";
  };

  services.nginx.virtualHosts."search.iw" = {
    listenAddresses = [ (intranet.ips.it-mil01) ];
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.searchiw.bind}";
    };
  };

  security.acme.certs."search.iw".server = "https://acme.iw/acme/directory";
}
