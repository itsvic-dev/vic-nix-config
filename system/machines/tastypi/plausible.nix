{ config, defaultSecretsFile, ... }:
{
  sops.secrets = {
    "plausible/secretKeybase" = {
      restartUnits = [ "plausible.service" ];
      sopsFile = defaultSecretsFile;
    };
  };

  services.plausible = {
    enable = true;
    server = {
      baseUrl = "https://plausible.itsvic.dev";
      secretKeybaseFile = config.sops.secrets."plausible/secretKeybase".path;
      port = 30953;
    };
  };

  services.nginx.virtualHosts."plausible.itsvic.dev" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.services.plausible.server.port}";
      proxyWebsockets = true;
    };
  };
}
