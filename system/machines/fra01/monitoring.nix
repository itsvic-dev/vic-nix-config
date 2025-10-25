{ intranet, config, ... }: {
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
    bind = {
      enable = true;
      openFirewall = true;
    };
  };

  services.nginx.statusPage = true;

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = 3101;
        grpc_listen_port = 0;
      };
      positions = { filename = "/tmp/positions.yaml"; };
      clients = [{ url = "http://tastypi.vic:3100/loki/api/v1/push"; }];
      scrape_configs = [{
        job_name = "journal";
        journal = {
          max_age = "12h";
          labels = { host = "tastypi"; };
        };
        relabel_configs = [{
          source_labels = [ "__journal__systemd_unit" ];
          target_label = "unit";
        }];
      }];
    };
  };
}
