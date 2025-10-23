{ config, pkgs, secretsPath, inputs, intranet, ... }: {
  imports = [ (intranet.getWireguardConfig "tastypi") ];

  sops.secrets.tastypi-vic-key = {
    owner = "nginx";
    sopsFile = intranet.getKey "tastypi" "tastypi.vic";
    format = "binary";
  };

  services.nginx.virtualHosts."tastypi.vic" = {
    root = ./tastypi-nginx;
    forceSSL = true;
    sslCertificate = intranet.getCert "tastypi" "tastypi.vic";
    sslCertificateKey = config.sops.secrets.tastypi-vic-key.path;
  };
}
