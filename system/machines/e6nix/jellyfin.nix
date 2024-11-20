{ config, ... }:
{
  sops.secrets = {
    jellyfin-tunnel = {
      owner = config.services.cloudflared.user;
      restartUnits = [ "cloudflared-tunnel-579c94c1-7a72-4da1-a29c-1a3ae14bf555.service" ];
      sopsFile = ../../../secrets/e6nix.yaml;
    };

    aria2-rpc-secret = {
      owner = "aria2";
      restartUnits = [ "aria2.service" ];
      sopsFile = ../../../secrets/e6nix.yaml;
    };
  };

  services = {
    jellyfin.enable = true;

    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = false; # not needed for now tbh
    prowlarr.enable = true;

    aria2 = {
      enable = true;
      settings.dir = "/var/jellyfin-media/Downloads";
      rpcSecretFile = config.sops.secrets.aria2-rpc-secret.path;
    };

    cloudflared = {
      enable = true;
      tunnels."579c94c1-7a72-4da1-a29c-1a3ae14bf555" = {
        credentialsFile = config.sops.secrets.jellyfin-tunnel.path;
        default = "http_status:404";

        ingress = {
          "jellyfin.itsvic.dev" = "http://localhost:8096";
          "sonarr.itsvic.dev" = "http://localhost:8989";
          "radarr.itsvic.dev" = "http://localhost:7878";
        };
      };
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/jellyfin-media";
      mode = "0777";
    }
  ];
}
