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
    bazarr.enable = true;
    aria2 = {
      enable = true;
      rpcSecretFile = config.sops.secrets.aria2-rpc-secret.path;
    };
  };

  environment.persistence."/persist".directories = [
    {
      directory = "/var/jellyfin-media";
      mode = "0777";
    }
  ];
}
