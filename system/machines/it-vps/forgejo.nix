{ config, intranet, ... }: {
  imports = [ (intranet.nginxCertFor "it-vps" "git.vic") ];

  services.forgejo = {
    enable = true;
    stateDir = "/mnt/hdd/forgejo";
    settings = {
      server = {
        DOMAIN = "git.vic";
        ROOT_URL = "https://git.vic/";
        PROTOCOL = "http+unix";
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
