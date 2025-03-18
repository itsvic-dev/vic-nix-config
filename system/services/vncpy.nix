{ config, lib, pkgs, inputs, ... }:
let
  vncpy = inputs.vncpy.packages.${pkgs.system}.default;
  cfg = config.services.vncpy;
in with lib; {
  options = {
    services.vncpy = {
      enable = mkEnableOption "vncpy";
      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to open the firewall port for vncpy.";
      };
      image = mkOption {
        type = types.path;
        description = "Image to use for vncpy.";
      };
    };
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = optionals cfg.openFirewall [ 5900 ];

    systemd.services."vncpy" = {
      wantedBy = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = "${vncpy}/bin/vncpy ${cfg.image}";
        Restart = "always";
      };
    };
  };
}
