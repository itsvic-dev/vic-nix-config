{
  config,
  pkgs,
  inputs,
  secretsPath,
  ...
}:
{
  imports = [
    ./networking.nix
    ./wings.nix
    ./hardware.nix
    ./free-media.nix
    ./grafana-prometheus.nix
    ./loki.nix
    ./vic-net

    inputs.oxibridge.nixosModules.default
  ];

  vic-nix = {
    server.enable = true;
    software.docker = true;
    hardware.bluetooth = true;
    hardware.hasEFI = false;
  };

  networking.wireless.iwd.enable = true;

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    commonHttpConfig = ''
      real_ip_header CF-Connecting-IP;
      log_format custom_log '[$time_iso8601] [$remote_addr] $request_method $host$uri';
      access_log /var/log/nginx/access.log custom_log;
    '';
  };

  services.logrotate.settings.nginx = {
    frequency = "daily";
    rotate = 7;
  };

  services.openssh.ports = [ 62122 ];

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.vncpy = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://static1.e621.net/data/sample/fa/f2/faf2cbcd6aa88473391af7b145a79690.jpg";
      hash = "sha256-80c4ycrJIkdb18BeklOopwunWmFTAGSeEcW6GJegNkU=";
    };
  };

  sops.secrets.oxibridge-config = {
    format = "yaml";
    sopsFile = "${secretsPath}/oxibridge.yml";
    key = "";
    restartUnits = [ "oxibridge.service" ];
  };

  services.oxibridge = {
    enable = true;
    configFile = config.sops.secrets.oxibridge-config.path;
  };

  users.users.nixremote = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM3Y1OlIZoZwu7XhxwD7O+R6ua99raUdZi+Ftqr00//X root@tastypi"
    ];
    group = "nixremote";
  };
  users.groups.nixremote = { };

  nix.settings.trusted-users = [ "nixremote" ];
}
