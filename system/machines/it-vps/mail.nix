{ config, inputs, ... }:
{
  sops.secrets.vic-email-pw = { };
  imports = [ inputs.nixos-mailserver.nixosModules.default ];

  users.users.nginx.extraGroups = [ "acme" ];
  services.nginx.virtualHosts."acmechallenge.itsvic.dev" = {
    serverAliases = [ "*.itsvic.dev" ];
    locations."/.well-known/acme-challenge" = {
      root = "/var/lib/acme/.challenges";
    };
    locations."/" = {
      return = "301 https://$host$request_uri";
    };
  };

  security.acme.certs.${config.mailserver.fqdn} = {
    webroot = "/var/lib/acme/.challenges";
    email = "contact@itsvic.dev";
    group = "nginx";
  };

  mailserver = {
    enable = true;
    stateVersion = 3;
    fqdn = "it-mil01.itsvic.dev";
    domains = [ "itsvic.dev" ];
    x509.useACMEHost = config.mailserver.fqdn;
    loginAccounts = {
      "contact@itsvic.dev" = {
        hashedPasswordFile = config.sops.secrets.vic-email-pw.path;
        aliases = [ "postmaster@itsvic.dev" ];
      };
    };
  };

  services.roundcube = {
    enable = true;
    hostName = "webmail.itsvic.dev";
    extraConfig = ''
      $config['imap_host'] = "ssl://${config.mailserver.fqdn}";
      $config['smtp_host'] = "ssl://${config.mailserver.fqdn}";
      $config['smtp_user'] = "%u";
      $config['smtp_pass'] = "%p";
    '';
  };
}
