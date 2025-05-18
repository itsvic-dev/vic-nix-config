{ config, lib, pkgs, inputs, secretsPath, ... }: {
  imports = [
    ./networking.nix
    ./wings.nix
    ./hardware.nix
    ./plausible.nix
    ./netdata.nix
    ./transmission.nix

    inputs.oxibridge.nixosModules.aarch64-linux.default
  ];

  vic-nix = {
    server = { enable = true; };
    software = {
      libvirt = true;
      docker = true;
    };
    hardware.bluetooth = true;
  };

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    commonHttpConfig = let
      realIpsFromList =
        lib.strings.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");
      fileToList = x: lib.strings.splitString "\n" (builtins.readFile x);
      cfipv4 = fileToList (pkgs.fetchurl {
        url = "https://www.cloudflare.com/ips-v4";
        sha256 = "0ywy9sg7spafi3gm9q5wb59lbiq0swvf0q3iazl0maq1pj1nsb7h";
      });
      cfipv6 = fileToList (pkgs.fetchurl {
        url = "https://www.cloudflare.com/ips-v6";
        sha256 = "1ad09hijignj6zlqvdjxv7rjj8567z357zfavv201b9vx3ikk7cy";
      });
    in ''
      ${realIpsFromList cfipv4}
      ${realIpsFromList cfipv6}
      real_ip_header CF-Connecting-IP;
    '';

    virtualHosts."social.itsvic.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:5254";
        proxyWebsockets = true;
      };
    };
  };

  services.openssh.ports = [ 62122 ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.bob-website = {
    enable = true;
    domain = "bob.itsvic.dev";
  };

  services.vncpy = {
    enable = true;
    image = pkgs.fetchurl {
      url =
        "https://static1.e621.net/data/sample/fa/f2/faf2cbcd6aa88473391af7b145a79690.jpg";
      hash = "sha256-80c4ycrJIkdb18BeklOopwunWmFTAGSeEcW6GJegNkU=";
    };
  };

  sops.secrets.oxibridge-config = {
    format = "yaml";
    sopsFile = "${secretsPath}/oxibridge.yml";
    key = "";

    restartUnits = [ "oxibridge.service" ];
    owner = "oxibridge";
  };

  services.oxibridge = {
    enable = true;
    configFile = config.sops.secrets.oxibridge-config.path;
  };
}
