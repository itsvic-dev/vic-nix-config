{ config, defaultSecretsFile, ... }:
{
  services.wings = {
    enable = true;
    port = 8443;
  };

  sops.secrets.cf-creds.sopsFile = defaultSecretsFile;

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "contact@itsvic.dev";
      dnsProvider = "cloudflare";
      environmentFile = config.sops.secrets.cf-creds.path;
    };
    certs."wings.itsvic.dev".postRun = ''
      systemctl restart wings
    '';
  };

  systemd.services.wings.requires = [ "acme-finished-wings.itsvic.dev.target" ];
}
