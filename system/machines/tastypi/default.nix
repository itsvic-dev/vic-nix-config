{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./networking.nix
    ./wings.nix
    ./hardware.nix
  ];

  vic-nix = {
    server = {
      enable = true;
    };
    software = {
      libvirt = true;
    };
    hardware.bluetooth = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    virtualHosts."social.itsvic.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5254";
        proxyWebsockets = true;
      };
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  services.bob-website = {
    enable = true;
    domain = "bob.itsvic.dev";
  };

  services.vncpy = {
    enable = true;
    image = pkgs.fetchurl {
      url = "https://static1.e621.net/data/sample/fa/f2/faf2cbcd6aa88473391af7b145a79690.jpg";
      hash = "sha256-80c4ycrJIkdb18BeklOopwunWmFTAGSeEcW6GJegNkU=";
    };
  };
}
