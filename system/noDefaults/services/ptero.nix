{
  pkgs,
  lib,
  config,
  ...
}:
let
  app = "pterodactyl";
  domain = "panel.local";
  dataDir = "/var/www/pterodactyl/public";
  user = config.services.nginx.user;
  myPhp = pkgs.php.withExtensions ({ enabled, all }: enabled ++ [ all.bz2 ]);
in
{
  networking.hosts."127.0.0.1" = [ domain ];

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
    phpEnv."PATH" = lib.makeBinPath [ myPhp ];
    phpPackage = myPhp;
  };

  services.mysql.enable = true;
  services.redis.servers."".enable = true;

  services.nginx = {
    enable = true;
    virtualHosts.${domain} = {
      root = dataDir;
      extraConfig = ''
        index = index.html index.htm index.php;
        client_max_body_size 100m;
        client_body_timeout 120s;
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
  };
}
