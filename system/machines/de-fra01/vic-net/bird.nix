{
  config,
  pkgs,
  intranet,
  ...
}:
{
  services.bird = {
    enable = true;
    package = pkgs.bird2;

    config = ''
      define OWNIP = ${intranet.ips.${config.networking.hostName}};
      router id OWNIP;

      include "${intranet.birdShared}";

      ${intranet.getAllIBGP config}
    '';
  };

  services.bird-lg.proxy = {
    enable = true;
    allowedIPs = [ "10.0.0.0/8" ];
    listenAddresses = "${intranet.ips.${config.networking.hostName}}:60134";
  };

  services.bird-lg.frontend = {
    enable = true;
    listenAddresses = "127.0.0.1:60130";
    whois = "10.21.0.1";
    domain = "vic";
    proxyPort = 60134;
    navbar.allServers = "All servers";
    servers = [
      "de-fra01"
      "pl-waw01"
      "it-mil01"
      "tastypi"
    ];
  };

  services.nginx.virtualHosts."lg.vic.iw" = {
    listenAddresses = [ "10.21.0.1" ];
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:60130";
    };
  };

  networking.firewall.allowedTCPPorts = [
    179
    60134
  ];
}
