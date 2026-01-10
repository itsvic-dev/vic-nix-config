{ lib }:
rec {
  caCert = ./certs/ca-cert.pem;
  nameserver = "10.21.0.1";

  wireguardPeers = {
    tastypi = {
      publicKey = "7yrI5RW+I6yZC5K1+7ErKUWC5h42aMYkjiP6/siOlzk=";
    };
    it-mil01 = {
      publicKey = "S2cSFcrvD4AzK7KuJTWpAzkYNMrdi2ojy8Owl+5VOU4=";
    };
    de-fra01 = {
      publicKey = "DGNfHXE4BWJJcDAxZRxBB5PIiCiSMFw2q7zNBQLEWBw=";
    };
    pl-waw01 = {
      publicKey = "7x8Xgdmb1thUqhl/22/s3aHNPOuzWt30UQo412EsSkE=";
    };

    mbp = {
      publicKey = "fyujyTR/I56g3bO79gLtwn7YgSxxq6O/Ct4NH5nRqlk=";
    };
    iphone = {
      publicKey = "AQqR0qBXROiHro05uJBbckiCWpuBzS8lTDsJIyhMxDI=";
    };
  };

  ips = {
    de-fra01 = "10.21.0.1";
    tastypi = "10.21.0.2";
    it-mil01 = "10.21.0.3";
    pl-waw01 = "10.21.0.4";

    mbp = "10.21.1.1";
    iphone = "10.21.1.2";
  };

  cnames = {
    "grafana" = "tastypi";
    "torrents" = "tastypi";
    "flood" = "tastypi";

    "hydra" = "pl-waw01";
    "cache" = "pl-waw01";

    "git" = "it-mil01";
  };

  ipsAsDNS = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (name: ip: "${name}.vic. IN A ${ip}") ips
  );

  cnamesAsDNS = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (name: target: "${name}.vic. IN CNAME ${target}.vic.") cnames
  );

  ipsAsRDNS = builtins.concatStringsSep "\n" (
    lib.mapAttrsToList (
      name: ip:
      let
        octets = lib.splitString "." ip;
        reversed = lib.concatStringsSep "." (lib.sublist 0 2 (lib.reverseList octets));
      in
      "${reversed} IN PTR ${name}.vic."
    ) ips
  );

  getCert = host: domain: ./certs/${host}/${domain}/cert.pem;
  getKey = host: domain: ./certs/${host}/${domain}/key.pem;

  wgXfrFor =
    {
      host,
      ip,
      listenPort ? 52900,
      endpoint ? null,
    }:
    { config, lib, ... }:
    {
      networking.wireguard.interfaces."vn-xfr-${host}" = {
        inherit listenPort;
        privateKeyFile = config.sops.secrets.vic-net-sk.path;
        allowedIPsAsRoutes = false;
        ips = [ ip ];

        peers = [
          {
            name = host;
            publicKey = wireguardPeers.${host}.publicKey;
            allowedIPs = [ "0.0.0.0/0" ];
            inherit endpoint;
          }
        ];
      };
      networking.firewall.allowedUDPPorts = lib.optional (endpoint == null) listenPort;
    };

  wgClientNet =
    {
      hosts,
      ip,
      listenPort ? 52900,
    }:
    { config, lib, ... }:
    {
      networking.wireguard.interfaces."vn-client-net" = {
        inherit listenPort;
        privateKeyFile = config.sops.secrets.vic-net-sk.path;
        ips = [ ip ];

        peers = map (host: {
          name = host;
          publicKey = wireguardPeers.${host}.publicKey;
          allowedIPs = [ "${ips.${host}}/32" ];
        }) hosts;
      };
      networking.firewall.allowedUDPPorts = [ listenPort ];
    };

  nginxCertFor =
    domain:
    { config, ... }:
    let
      host = config.networking.hostName;
    in
    {
      sops.secrets."${domain}.key" = {
        owner = config.services.nginx.user;
        sopsFile = getKey host domain;
        format = "binary";
      };
      services.nginx.virtualHosts."${domain}" = {
        sslCertificate = getCert host domain;
        sslCertificateKey = config.sops.secrets."${domain}.key".path;
      };
    };

  birdShared = ./bird-shared.conf;
}
