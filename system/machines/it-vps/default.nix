{ config, lib, pkgs, inputs, ... }:
let bob = inputs.bob.packages.x86_64-linux.default;
in {
  imports = [
    ./hardware.nix
    ./ptero.nix
    ./staticnetwork.nix
    ./cloudflared.nix
    ./plausible.nix
  ];

  vic-nix = {
    server.enable = true;
    software.docker = true;
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
  };
}
