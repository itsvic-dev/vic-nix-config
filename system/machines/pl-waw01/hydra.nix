{
  config,
  secretsPath,
  intranet,
  pkgs,
  ...
}:
{
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.vic";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    port = 4023;
    extraConfig = ''
      max_output_size ${toString (5 * 1024 * 1024 * 1024)}
    '';
  };

  nix = {
    settings.allowed-uris = [
      "github:"
      "git+https://github.com/"
      "git+ssh://github.com/"
    ];
    extraOptions = ''
      builders-use-substitutes = true
      !include ${config.sops.secrets.nixAccessTokens.path}
    '';

    buildMachines = [
      {
        hostName = "it-mil01.vic";
        systems = [
          "x86_64-linux"
          "i686-linux"
        ];
        protocol = "ssh";
        maxJobs = 4;
        speedFactor = 1;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }
      {
        hostName = "de-fra01.vic";
        systems = [
          "x86_64-linux"
          "i686-linux"
        ];
        protocol = "ssh";
        maxJobs = 4;
        speedFactor = 1;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }
      {
        hostName = "tastypi.vic";
        system = "aarch64-linux";
        protocol = "ssh";
        maxJobs = 4;
        speedFactor = 1;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }
      # hydra freaks out sometimes without this
      {
        hostName = "localhost";
        protocol = null;
        systems = [
          "x86_64-linux"
          "i686-linux"
        ];
        supportedFeatures = [
          "kvm"
          "nixos-test"
          "big-parallel"
          "benchmark"
        ];
        maxJobs = 6;
        speedFactor = 4;
      }
    ];

    distributedBuilds = true;
  };

  sops.secrets = {
    hydra-vic-key = {
      owner = "nginx";
      sopsFile = intranet.getKey "pl-waw01" "hydra.vic";
      format = "binary";
    };
    cache-vic-key = {
      owner = "nginx";
      sopsFile = intranet.getKey "pl-waw01" "cache.vic";
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
    package = pkgs.nix-serve-ng;
    port = 9620;
    bindAddress = "127.0.0.1";
    secretKeyFile = config.sops.secrets.binary-cache-key.path;
  };

  services.nginx.virtualHosts = {
    "hydra.vic" = {
      forceSSL = true;
      sslCertificate = intranet.getCert "pl-waw01" "hydra.vic";
      sslCertificateKey = config.sops.secrets.hydra-vic-key.path;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.hydra.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
    "cache.vic" = {
      forceSSL = true;
      sslCertificate = intranet.getCert "pl-waw01" "cache.vic";
      sslCertificateKey = config.sops.secrets.cache-vic-key.path;
      locations."/" = {
        proxyPass = "http://localhost:${toString config.services.nix-serve.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };
}
