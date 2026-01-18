{
  config,
  intranet,
  inputs,
  ...
}:
{
  imports = [ inputs.searchiw.nixosModules.default ];
  services.searchiw = {
    enable = true;
    bind = "127.0.0.1:7665";
  };

  services.nginx.virtualHosts."search.iw" = {
    listenAddresses = [ (intranet.ips.pl-waw01) ];
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://${config.services.searchiw.bind}";
    };
  };

  security.acme.certs."search.iw".server = "https://acme.iw/acme/directory";
}
