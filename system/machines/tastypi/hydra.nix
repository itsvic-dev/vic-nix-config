{ config, secretsPath, ... }: {
  services.hydra = {
    enable = true;
    hydraURL = "https://hydra.vic";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
    port = 4023;
    extraConfig = ''
      <hydra_notify>
        <prometheus>
          listen_address = 127.0.0.1
          port = 9199
        </prometheus>
      </hydra_notify>
    '';
  };

  nix = {
    settings.allowed-uris =
      [ "github:" "git+https://github.com/" "git+ssh://github.com/" ];
    extraOptions = ''
      builders-use-substitutes = true
      !include ${config.sops.secrets.nixAccessTokens.path}
    '';

    buildMachines = [{
      hostName = "it-vps.vic";
      system = "x86_64-linux";
      protocol = "ssh-ng";
      maxJobs = 2;
      speedFactor = 1;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }];
  };

  sops.secrets = {
    hydra-vic-key = {
      owner = "nginx";
      sopsFile = "${secretsPath}/hydra.vic.key";
      format = "binary";
    };
    nixAccessTokens = {
      group = config.users.groups.keys.name;
      sopsFile = "${secretsPath}/nix-auth.conf";
      format = "binary";
      mode = "0440";
    };
  };

  users.users = {
    hydra.extraGroups = [ config.users.groups.keys.name ];
    vic.extraGroups = [ config.users.groups.keys.name ];
  };
  users.groups.keys = { };

  services.nginx.virtualHosts."hydra.vic" = {
    forceSSL = true;
    sslCertificate = ../../../ca/hydra.vic/cert.pem;
    sslCertificateKey = config.sops.secrets.hydra-vic-key.path;
    locations."/" = {
      proxyPass = "http://localhost:${toString config.services.hydra.port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
    };
  };
}
