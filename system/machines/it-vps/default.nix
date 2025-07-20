{ config, lib, pkgs, inputs, ... }:
let bob = inputs.bob.packages.x86_64-linux.default;
in {
  imports =
    [ ./hardware.nix ./ptero.nix ./staticnetwork.nix ./cloudflared.nix ];

  vic-nix = {
    server = { enable = true; };
    software = { docker = true; };
  };

  services.qemuGuest.enable = true;
  services.netdata.enable = true;

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

  systemd.services."vyltrix-bot" = {
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/home/vic/vyltrix/bot/venv/bin/python main.py";
      User = "vic";
      Restart = "always";
      WorkingDirectory = "/home/vic/vyltrix/bot";
    };
  };

  services.nginx = {
    enable = true;
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

    virtualHosts."birdie.itsvic.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:4000";
        proxyWebsockets = true;
      };
    };
  };
}
