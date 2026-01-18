{
  pkgs,
  lib,
  config,
  ...
}:
let
  app = "pterodactyl";
  domain = "panel.itsvic.dev";
  demoDomain = "demo.itsvic.dev";
  dataDir = "/var/www/pterodactyl";
  demoDataDir = "/var/www/pterodactyl-demo";
  user = config.services.nginx.user;

  defineVHost = domain: dataDir: {
    root = "${dataDir}/public";
    extraConfig = ''
      index = index.html index.htm index.php;
      client_max_body_size 100m;
      client_body_timeout 120s;
      allow 127.0.0.1;
      allow ::1;
      deny all;
      access_log /var/log/nginx/${domain}.access.log realip_cf;
    '';
    locations."/" = {
      extraConfig = ''
        try_files $uri $uri/ /index.php?$query_string;
      '';
    };
    locations."~ \\.php$" = {
      extraConfig = ''
        fastcgi_pass unix:${config.services.phpfpm.pools.${app}.socket};
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_index index.php;
        include ${pkgs.nginx}/conf/fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size=100M";
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
      '';
    };
  };
in
{
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  services.redis.servers."" = {
    enable = true;
  };
  services.phpfpm.pools.${app} = {
    inherit user;
    settings = {
      "listen.owner" = user;
      "pm" = "dynamic";
      "pm.max_children" = 32;
      "pm.max_requests" = 500;
      "pm.start_servers" = 2;
      "pm.min_spare_servers" = 2;
      "pm.max_spare_servers" = 5;
      "php_admin_value[error_log]" = "stderr";
      "php_admin_flag[log_errors]" = true;
      "catch_workers_output" = true;
    };
    phpEnv."PATH" = lib.makeBinPath [ pkgs.php ];
  };

  services.nginx = {
    virtualHosts.${domain} = defineVHost domain dataDir;
    virtualHosts.${demoDomain} = defineVHost demoDomain demoDataDir;
  };

  systemd.timers."pterodactyl-schedule" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnUnitActiveSec = "1m";
      Unit = "pterodactyl-schedule.service";
    };
  };

  systemd.services."pterodactyl-schedule" = {
    script = ''
      set -eu
      ${pkgs.php}/bin/php ${demoDataDir}/artisan schedule:run
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    unitConfig = {
      StartLimitInterval = 0;
    };
  };

  systemd.timers."db-restore" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/15";
      Unit = "db-restore.service";
    };
  };

  systemd.services."db-restore" = {
    script = ''
      set -eu
      ${pkgs.systemd}/bin/systemctl stop mysql
      ${pkgs.rsync}/bin/rsync -a /var/mariadb/backup/. /var/lib/mysql/. --delete-after --chown=mysql:mysql
      ${pkgs.systemd}/bin/systemctl start mysql
      ${pkgs.php}/bin/php ${demoDataDir}/artisan cache:clear
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
