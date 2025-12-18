{
  config,
  intranet,
  ...
}:
{
  sops.secrets = {
    grafana-vic-key = {
      owner = "nginx";
      sopsFile = intranet.getKey "tastypi" "grafana.vic";
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

    scrapeConfigs = [
      {
        job_name = "tastypi";
        static_configs = [
          {
            targets = [
              "127.0.0.1:${toString config.services.prometheus.exporters.node.port}"
              "127.0.0.1:${toString config.services.prometheus.exporters.nginx.port}"
            ];
          }
        ];
      }
      {
        job_name = "it-vps";
        static_configs = [
          {
            targets = [
              "it-vps.vic:${toString config.services.prometheus.exporters.node.port}"
              "it-vps.vic:${toString config.services.prometheus.exporters.nginx.port}"
            ];
          }
        ];
      }
      {
        job_name = "fra01";
        static_configs = [
          {
            targets = [
              "fra01.vic:${toString config.services.prometheus.exporters.node.port}"
              "fra01.vic:${toString config.services.prometheus.exporters.nginx.port}"
              "fra01.vic:${toString config.services.prometheus.exporters.bind.port}"
            ];
          }
        ];
      }
    ];
  };

  services.nginx = {
    statusPage = true;
    virtualHosts.${config.services.grafana.settings.server.domain} = {
      listenAddresses = [ (intranet.ips.tastypi) ];
      forceSSL = true;
      sslCertificate = intranet.getCert "tastypi" "grafana.vic";
      sslCertificateKey = config.sops.secrets.grafana-vic-key.path;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.grafana.settings.server.http_port}";
        proxyWebsockets = true;
      };
    };
  };
}
