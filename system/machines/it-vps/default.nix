{ config, lib, pkgs, inputs, intranet, ... }:
let bob = inputs.bob.packages.x86_64-linux.default;
in {
  imports = [
    ./hardware.nix
    ./ptero.nix
    ./staticnetwork.nix
    ./cloudflared.nix
    ./plausible.nix
    ./loki.nix
    ./forgejo.nix

    (intranet.getWireguardConfig "it-vps")
  ];

  vic-nix = {
    server.enable = true;
    software.docker = true;
  };

  services.qemuGuest.enable = true;

  security.acme = {
    acceptTerms = true;
    defaults.email = "contact@itsvic.dev";
  };

  systemd.services."bob" = {
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${bob}/bin/bob";
      User = "vic";
      Restart = "always";
      WorkingDirectory = "/mnt/hdd/bob";
    };
  };

  services.nginx = {
    enable = true;
    statusPage = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    additionalModules = with pkgs.nginxModules; [ fancyindex ];
    commonHttpConfig = ''
      log_format realip_cf '$http_cf_connecting_ip $http_x_forwarded_for - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
    '';
  };

  services.prometheus.exporters = {
    node = {
      enable = true;
      enabledCollectors = [ "systemd" ];
      port = 9002;
      openFirewall = true;
      listenAddress = intranet.ips.${config.networking.hostName};
    };
    nginx = {
      enable = true;
      openFirewall = true;
    };
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
