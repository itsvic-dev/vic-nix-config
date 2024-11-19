{ config, ... }:
{
  sops.secrets.aria2-rpc-secret = {
    owner = "aria2";
    restartUnits = [ "aria2.service" ];
    sopsFile = ../../../secrets/e6nix.yaml;
  };

  services = {
    jellyfin.enable = true;

    sonarr.enable = true;
    radarr.enable = true;
    bazarr.enable = false; # not needed for now tbh
    prowlarr.enable = true;

    aria2 = {
      enable = true;
      rpcSecretFile = config.sops.secrets.aria2-rpc-secret.path;
    };

    nginx = {
      enable = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts."jellyfin.itsvic.dev" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:8096";
          proxyWebsockets = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  security.acme = {
    acceptTerms = true;
    defaults = {
      email = "contact@itsvic.dev";
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/jellyfin-media";
      mode = "0777";
    }
  ];
}
