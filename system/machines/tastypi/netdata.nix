{ config, defaultSecretsFile, ... }: {
  sops.secrets = {
    cloudflared = {
      restartUnits =
        [ "cloudflared-tunnel-4b18018a-7a34-46f3-b3b6-2337bf1612bb.service" ];
      sopsFile = defaultSecretsFile;
    };
  };

  services.netdata.enable = true;

  services.cloudflared = {
    enable = true;
    tunnels = {
      "4b18018a-7a34-46f3-b3b6-2337bf1612bb" = {
        credentialsFile = config.sops.secrets.cloudflared.path;
        ingress = { "netdata-tastypi.itsvic.dev" = "http://localhost:19999"; };
        default = "http_status:404";
      };
    };
  };
}
