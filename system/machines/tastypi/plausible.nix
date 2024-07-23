{ config, ... }:
{
  sops.secrets = {
    "plausible/secretKeybase" = {
      restartUnits = [ "plausible.service" ];
      sopsFile = ../../../secrets/tastypi.yaml;
    };
    "plausible/adminPass" = {
      restartUnits = [ "plausible.service" ];
      sopsFile = ../../../secrets/tastypi.yaml;
    };
  };

  services.plausible = {
    enable = true;
    adminUser = {
      activate = true;
      name = "itsvic";
      email = "contact@itsvic.dev";
      passwordFile = config.sops.secrets."plausible/adminPass".path;
    };
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
