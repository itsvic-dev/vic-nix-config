{
  intranet,
  ...
}:
{
  imports = [
    intranet.wireguardConfig
    (intranet.nginxCertFor "tastypi.vic")
  ];

  services.nginx.virtualHosts."tastypi.vic" = {
    root = ./tastypi-nginx;
    listenAddresses = [ (intranet.ips.tastypi) ];
    forceSSL = true;
  };
}
