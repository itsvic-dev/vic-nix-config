{ pkgs, ... }: {
  services.rtorrent = {
    enable = true;
    openFirewall = true;
    dataPermissions = "0755";
  };

  services.flood = {
    enable = true;
    openFirewall = true;
    host = "0.0.0.0";
  };
}
