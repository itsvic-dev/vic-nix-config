{ config, secretsPath, ... }: {
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.vic";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    port = 4023;
  };

  nix = {
    settings.allowed-uris =
      [ "github:" "git+https://github.com/" "git+ssh://github.com/" ];
    extraOptions = ''
      builders-use-substitutes = true
      !include ${config.sops.secrets.nixAccessTokens.path}
    '';

    buildMachines = [
      {
        hostName = "it-vps.vic";
        system = "x86_64-linux";
        protocol = "ssh";
        maxJobs = 2;
        speedFactor = 1;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }
      {
        hostName = "fra01.vic";
        system = "x86_64-linux";
        protocol = "ssh";
        maxJobs = 2;
        speedFactor = 2;
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }
      # hydra freaks out sometimes without this
      {
        hostName = "localhost";
        protocol = null;
        system = "aarch64-linux";
        supportedFeatures = [ "kvm" "nixos-test" "big-parallel" "benchmark" ];
        maxJobs = 4;
      }
    ];

    distributedBuilds = true;
  };

  sops.secrets = {
    hydra-vic-key = {
      owner = "nginx";
      sopsFile = "${secretsPath}/hydra.vic.key";
      format = "binary";
    };
    cache-vic-key = {
      owner = "nginx";
      sopsFile = "${secretsPath}/cache.vic.key";
      format = "binary";
    };
    binary-cache-key = {
      owner = "nginx";
      sopsFile = "${secretsPath}/binary-cache.key";
      format = "binary";
    };
    nixAccessTokens = {
      group = config.users.groups.keys.name;
      sopsFile = ../../../secrets/nix-auth.conf;
      format = "binary";
      mode = "0440";
    };
  };

  users.users = {
    hydra.extraGroups = [ config.users.groups.keys.name ];
    vic.extraGroups = [ config.users.groups.keys.name ];
  };
  users.groups.keys = { };

  services.nix-serve = {
    enable = true;
    port = 9620;
    bindAddress = "127.0.0.1";
    secretKeyFile = config.sops.secrets.binary-cache-key.path;
  };

  services.nginx.virtualHosts = {
    "hydra.vic" = {
      forceSSL = true;
      sslCertificate = ../../../ca/hydra.vic/cert.pem;
      sslCertificateKey = config.sops.secrets.hydra-vic-key.path;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.hydra.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
    "cache.vic" = {
      forceSSL = true;
      sslCertificate = ../../../ca/cache.vic/cert.pem;
      sslCertificateKey = config.sops.secrets.cache-vic-key.path;
      locations."/" = {
        proxyPass =
          "http://localhost:${toString config.services.nix-serve.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
