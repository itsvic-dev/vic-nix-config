{
  services.nginx = {
    enable = true;
    virtualHosts = {
      "intraweb.com" = {
        locations."/" = {
          extraConfig = ''
            return 301 $scheme://www.intraweb.com$request_uri;
          '';
        };
      };

      "www.intraweb.com" = {
        root = ./www/intraweb.com;
      };

      # used by windows's network check
      "www.msftncsi.com" = {
        root = ./www/msftncsi.com;
      };

      # modern equivalent
      "www.msftconnecttest.com" = {
        root = ./www/msftncsi.com;
      };
    };
  };
}
