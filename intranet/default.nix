{ lib }:
rec {
  caCert = ./certs/ca-cert.pem;
  nameserver = "10.21.0.1";

  peers = {
    de-fra01 = {
      publicKey = "DGNfHXE4BWJJcDAxZRxBB5PIiCiSMFw2q7zNBQLEWBw=";
      ip = "10.21.0.1";
    };

    tastypi = {
      publicKey = "7yrI5RW+I6yZC5K1+7ErKUWC5h42aMYkjiP6/siOlzk=";
      ip = "10.21.0.2";
    };

    it-mil01 = {
      publicKey = "S2cSFcrvD4AzK7KuJTWpAzkYNMrdi2ojy8Owl+5VOU4=";
      ip = "10.21.0.3";
      clearnetIP = "5.231.80.191";
    };

    pl-waw01 = {
      publicKey = "7x8Xgdmb1thUqhl/22/s3aHNPOuzWt30UQo412EsSkE=";
      ip = "10.21.0.4";
      clearnetIP = "109.122.28.203";
    };

    # --------- clients ---------
    mbp = {
      publicKey = "fyujyTR/I56g3bO79gLtwn7YgSxxq6O/Ct4NH5nRqlk=";
      ip = "10.21.0.254";
    };
    iphone = {
      publicKey = "AQqR0qBXROiHro05uJBbckiCWpuBzS8lTDsJIyhMxDI=";
      ip = "10.21.0.253";
    };
  };
  wireguardPeers = peers;

  # the actual transfer networks
  # IPs derived from the 'id' field
  wires = [
    {
      from = "it-mil01";
      to = "tastypi";
      id = 1;
    }

    {
      from = "pl-waw01";
      to = "it-mil01";
      id = 2;
    }
  ];

  cnames = {
    "grafana" = "tastypi";
    "torrents" = "tastypi";
    "flood" = "tastypi";

    "hydra" = "pl-waw01";
    "cache" = "pl-waw01";

    "git" = "it-mil01";
  };

  # ----------------------------- MACHINERY BELOW -----------------------------

  ips = lib.mapAttrs (name: peer: peer.ip) peers;

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

  getWireguardTransfersFrom =
    config:
    let
      name = config.networking.hostName;
    in
    lib.genAttrs' (builtins.filter (wire: wire.from == name) wires) (
      wire:
      lib.nameValuePair "vn-wg-${wire.to}" {
        listenPort = 51900 + wire.id;
        privateKeyFile = config.sops.secrets.vic-net-sk.path;
        allowedIPsAsRoutes = false;
        ips = [ "fd21:f01f:ca75:${toString wire.id}::1/64" ];

        peers = [
          {
            name = wire.to;
            allowedIPs = [ "::/0" ];
            inherit (peers.${wire.to}) publicKey;
          }
        ];
      }
    );

  getWireguardTransfersTo =
    config:
    let
      name = config.networking.hostName;
    in
    lib.genAttrs' (builtins.filter (wire: wire.to == name) wires) (
      wire:
      lib.nameValuePair "vn-wg-${wire.from}" {
        listenPort = 51900 + wire.id;
        privateKeyFile = config.sops.secrets.vic-net-sk.path;
        allowedIPsAsRoutes = false;
        ips = [ "fd21:f01f:ca75:${toString wire.id}::2/64" ];

        peers = [
          {
            name = wire.from;
            allowedIPs = [ "::/0" ];
            inherit (peers.${wire.from}) publicKey;
            endpoint = "${peers.${wire.from}.clearnetIP}:${toString (51900 + wire.id)}";
          }
        ];
      }
    );

  getGRENetdev =
    name: wire:
    let
      isFrom = wire.from == name;
      tunnelName = if isFrom then "vn-gre-${wire.to}" else "vn-gre-${wire.from}";
      remoteIP =
        if isFrom then "fd21:f01f:ca75:${toString wire.id}::2" else "fd21:f01f:ca75:${toString wire.id}::1";
      localIP =
        if isFrom then "fd21:f01f:ca75:${toString wire.id}::1" else "fd21:f01f:ca75:${toString wire.id}::2";
    in
    lib.nameValuePair "99-${tunnelName}" {
      netdevConfig = {
        Name = tunnelName;
        Kind = "ip6gre";
      };

      tunnelConfig = {
        Remote = remoteIP;
        Local = localIP;
      };
    };

  # just a stub so networkd brings up the interfaces
  getGRENetwork =
    name: wire:
    let
      isFrom = wire.from == name;
      tunnelName = if isFrom then "vn-gre-${wire.to}" else "vn-gre-${wire.from}";
    in
    lib.nameValuePair "99-${tunnelName}" {
      matchConfig.Name = tunnelName;
    };

  getGRETunnelOverride =
    name: wire:
    let
      isFrom = wire.from == name;
      ifname = if isFrom then wire.to else wire.from;
    in
    lib.nameValuePair "40-vn-wg-${ifname}" {
      networkConfig.Tunnel = "vn-gre-${ifname}";
    };

  getThingFrom =
    getThing: config:
    let
      name = config.networking.hostName;
    in
    lib.genAttrs' (builtins.filter (wire: wire.from == name) wires) (wire: getThing name wire);

  getThingTo =
    getThing: config:
    let
      name = config.networking.hostName;
    in
    lib.genAttrs' (builtins.filter (wire: wire.to == name) wires) (wire: getThing name wire);

  transfers =
    { config, ... }:
    {
      networking.wireguard.interfaces =
        (getWireguardTransfersFrom config) // (getWireguardTransfersTo config);

      systemd.network.netdevs = (getThingFrom getGRENetdev config) // (getThingTo getGRENetdev config);
      systemd.network.networks =
        (getThingFrom getGRENetwork config)
        // (getThingTo getGRENetwork config)
        // (getThingFrom getGRETunnelOverride config)
        // (getThingTo getGRETunnelOverride config);

      networking.firewall.allowedUDPPorts = map (wire: 51900 + wire.id) (
        builtins.filter (wire: wire.from == config.networking.hostName) wires
      );

      networking.firewall.extraCommands = ''
        ip6tables -A INPUT -p 47 -j ACCEPT
      '';
    };

  dummy =
    { config, ... }:
    {
      systemd.network = {
        netdevs.vn-dummy.netdevConfig = {
          Kind = "dummy";
          Name = "vn-dummy";
        };

        networks.vn-dummy = {
          matchConfig.Name = "vn-dummy";
          networkConfig.Address = peers.${config.networking.hostName}.ip + "/32";
        };
      };
    };

  getCert = host: domain: ./certs/${host}/${domain}/cert.pem;
  getKey = host: domain: ./certs/${host}/${domain}/key.pem;

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

  sysctls = {
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.rp_filter" = 0;
      "net.ipv4.conf.default.rp_filter" = 0;
    };
  };

  birdShared = ./bird-shared.conf;
}
