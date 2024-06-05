{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  # note: assuming amd646
  wingsBinarySource =
    ({
      "x86_64-linux" = {
        url = "https://github.com/pterodactyl/wings/releases/download/v1.11.13/wings_linux_amd64";
        sha256 = "1z5qjrvk3vllh3wn8y4mdfqc8p74l4f4qbjmxy9yad1ldqkcs1ib";
      };
      "aarch64-linux" = {
        url = "https://github.com/pterodactyl/wings/releases/download/v1.11.13/wings_linux_arm64";
        sha256 = "0xznav37lg9gz4v6lclclwd6m93xda0gyi5n3b7s0vs9fhzycjvj";
      };
    }).${pkgs.system};

  wingsBinary = pkgs.fetchurl {
    inherit (wingsBinarySource) url sha256;
    executable = true;
  };

  cfg = config.services.wings;
in
{
  options = {
    services.wings = {
      enable = mkEnableOption "Wings";
      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to open the firewall port for Wings.";
      };
      port = mkOption {
        type = types.int;
        default = 8080;
        description = "Port that Wings uses for HTTP.";
      };
    };
  };

  config = mkIf cfg.enable {
    users.users.pterodactyl = {
      isSystemUser = true;
      group = "pterodactyl";
    };
    users.groups.pterodactyl = { };

    networking.firewall.allowedTCPPorts = optionals cfg.openFirewall [ cfg.port ];

    systemd.services."wings" = {
      wantedBy = [ "network-online.target" ];
      serviceConfig = {
        ExecStart = wingsBinary;
        Restart = "always";
      };
    };
  };
}
