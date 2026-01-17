{ intranet, ... }:
{
  imports = [
    (intranet.nginxCertFor "acme.iw")
  ];

  services.nginx.virtualHosts = {
    "acme.iw" = {
      listenAddresses = [ "10.21.0.1" ];
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8080";
      };
      locations."= /ca.pem" = {
        alias = intranet.intrawebCaCert;
      };
    };
  };
}
