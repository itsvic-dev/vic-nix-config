{ intranet, pkgs, ... }:
{
  services.vsftpd = {
    enable = true;
    writeEnable = true;
    anonymousUser = true;
    anonymousUserHome = "/mnt/data/intraweb-ftp";
    anonymousUploadEnable = true;
    anonymousMkdirEnable = true;
    anonymousUserNoPassword = true;
    anonymousUmask = "002";
    extraConfig = ''
      ftpd_banner=Welcome to Intraweb FTP! Please read README file first.
      anon_other_write_enable=YES
      listen_address=10.21.0.4

      ftp_data_port=20
      pasv_enable=YES
      pasv_min_port=64000
      pasv_max_port=64321
      port_enable=YES
    '';
  };

  networking.firewall.allowedTCPPorts = [
    20
    21
  ];
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 64000;
      to = 64321;
    }
  ];

  services.nginx.virtualHosts."ftp.vic.iw" = {
    listenAddresses = [ (intranet.ips.pl-waw01) ];
    forceSSL = true;
    enableACME = true;
    locations."/" = {
      root = "/mnt/data/intraweb-ftp";
      extraConfig = ''
        autoindex on;
        fancyindex on;
        fancyindex_exact_size off;
      '';
    };
  };
  services.nginx.additionalModules = [ pkgs.nginxModules.fancyindex ];

  security.acme.certs."ftp.vic.iw".server = "https://acme.iw/acme/directory";
}
