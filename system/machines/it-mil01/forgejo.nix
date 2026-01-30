{
  pkgs,
  config,
  intranet,
  ...
}:
{
  imports = [ (intranet.nginxCertFor "git.vic") ];

  services.forgejo = {
    enable = true;
    package = pkgs.forgejo;
    stateDir = "/mnt/hdd/forgejo";
    settings = {
      DEFAULT.APP_NAME = "vic!Git";
      server = {
        DOMAIN = "git.vic";
        ROOT_URL = "https://git.vic.iw/";
        PROTOCOL = "http+unix";
      };
      repository = {
        DEFAULT_BRANCH = "trunk";
        USE_COMPAT_SSH_URI = false;
      };
    };
  };

  services.nginx = {
    virtualHosts."git.vic.iw" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://forgejo";
        proxyWebsockets = true;
      };
    };

    virtualHosts."git.vic" = {
      addSSL = true;
      globalRedirect = "git.vic.iw";
    };

    upstreams.forgejo = {
      servers = {
        "unix:${config.services.forgejo.settings.server.HTTP_ADDR}" = { };
      };
    };
  };

  security.acme.certs."git.vic.iw".server = "https://acme.iw/acme/directory";
}
