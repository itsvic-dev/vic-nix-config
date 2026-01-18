{ intranet, ... }:
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
    '';
  };

  networking.firewall.allowedTCPPorts = [ 21 ];

  services.nginx.virtualHosts."ftp.vic.iw" = {
    listenAddresses = [ (intranet.ips.pl-waw01) ];
    forceSSL = true;
    enableACME = true;
    root = "/mnt/data/intraweb-ftp";
  };

  security.acme.certs."ftp.vic.iw".server = "https://acme.iw/acme/directory";
}
