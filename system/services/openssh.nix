{ config, lib, ... }:
let
  cfg = config.vic-nix.server;
in
{
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };
  };
}
