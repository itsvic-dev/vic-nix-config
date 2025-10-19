{ config, pkgs, inputs, secretsPath, ... }: {
  sops.secrets = {
    grafana-vic-key = {
      owner = "nginx";
      sopsFile = "${secretsPath}/grafana.vic.key";
      format = "binary";
    };
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        domain = "grafana.vic";
        enforce_domain = true;
        enable_gzip = true;
        http_port = 2342;
        http_addr = "127.0.0.1";
        root_url = "https://grafana.vic/";
      };
    };
  };

  services.prometheus = {
    enable = true;
    port = 9001;

    globalConfig.scrape_interval = "10s";

    exporters = {
      node = {
        enable = true;
        enabledCollectors = [ "systemd" ];
        port = 9002;
      };
      nginx.enable = true;
    };

    scrapeConfigs = [{
      job_name = "tastypi";
      static_configs = [{
        targets = [
          "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
          "127.0.0.1:${
            toString config.services.prometheus.exporters.nginx.port
          }"
        ];
      }];
    }];
  };

  services.nginx = {
    statusPage = true;
    virtualHosts.${config.services.grafana.settings.server.domain} = {
      forceSSL = true;
      sslCertificate = "${inputs.self}/ca/grafana.vic/cert.pem";
      sslCertificateKey = config.sops.secrets.grafana-vic-key.path;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${
            toString config.services.grafana.settings.server.http_port
          }";
        proxyWebsockets = true;
      };
    };
  };
}
