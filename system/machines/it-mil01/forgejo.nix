{ config, intranet, ... }:
{
  imports = [ (intranet.nginxCertFor "git.vic") ];

  services.forgejo = {
    enable = true;
    stateDir = "/mnt/hdd/forgejo";
    settings = {
      DEFAULT.APP_NAME = "vic!Git";
      server = {
        DOMAIN = "git.vic";
        ROOT_URL = "https://git.vic/";
        PROTOCOL = "http+unix";
      };
      repository = {
        DEFAULT_BRANCH = "trunk";
        USE_COMPAT_SSH_URI = false;
      };
    };
  };

  services.nginx = {
    virtualHosts."git.vic" = {
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://forgejo";
        proxyWebsockets = true;
      };
    };

    upstreams.forgejo = {
      servers = {
        "unix:${config.services.forgejo.settings.server.HTTP_ADDR}" = { };
      };
    };
  };
}
