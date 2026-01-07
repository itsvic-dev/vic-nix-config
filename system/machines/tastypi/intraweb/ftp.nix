{
  services.vsftpd = {
    enable = true;
    writeEnable = true;
    anonymousUser = true;
    anonymousUserHome = "/mnt/ssd/intraweb-ftp";
    anonymousUploadEnable = true;
    anonymousMkdirEnable = true;
    anonymousUserNoPassword = true;
    anonymousUmask = "002";
    extraConfig = ''
      ftpd_banner=Welcome to Intraweb FTP! Please read README file first.
      anon_other_write_enable=YES
    '';
  };

  systemd.services.vsftpd = {
    requires = [ "intraweb-netns.service" ];
    serviceConfig.NetworkNamespacePath = "/run/netns/intraweb";
  };
}
