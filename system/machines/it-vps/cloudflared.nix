{ config, defaultSecretsFile, ... }: {
  sops.secrets = {
    "cloudflared/2e679b98-a35a-4c13-84f1-b9296bc55bb2" = {
      owner = config.services.cloudflared.user;
      restartUnits =
        [ "cloudflared-tunnel-2e679b98-a35a-4c13-84f1-b9296bc55bb2.service" ];
      sopsFile = defaultSecretsFile;
    };
    "cloudflared/90d18543-7a60-47d1-805f-ec1ee80ea962" = {
      owner = config.services.cloudflared.user;
      restartUnits =
        [ "cloudflared-tunnel-90d18543-7a60-47d1-805f-ec1ee80ea962.service" ];
      sopsFile = defaultSecretsFile;
    };
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "2e679b98-a35a-4c13-84f1-b9296bc55bb2" = {
        credentialsFile =
          config.sops.secrets."cloudflared/2e679b98-a35a-4c13-84f1-b9296bc55bb2".path;
        ingress = {
          "furrygpt.com" = "http://localhost:49361";
          "www.furrygpt.com" = "http://localhost:49361";
          "netdata.itsvic.dev" = "http://localhost:19999";
        };
        default = "http_status:404";
      };

      "90d18543-7a60-47d1-805f-ec1ee80ea962" = {
        credentialsFile =
          config.sops.secrets."cloudflared/90d18543-7a60-47d1-805f-ec1ee80ea962".path;
        ingress = {
          "panel.itsvic.dev" = "http://localhost:80";
          "demo.itsvic.dev" = "http://localhost:80";
          "glitchtip.itsvic.dev" = "http://localhost:8495";
          "social.itsvic.dev" = "http://localhost:5254";
          "transmission.itsvic.dev" = "http://localhost:${
              toString config.services.transmission.settings.rpc-port
            }";
        };
        default = "http_status:404";
      };
    };
  };
}
