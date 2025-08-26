{ config, defaultSecretsFile, ... }: {
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
}
