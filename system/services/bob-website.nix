{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.services.bob-website;
in
{
  options = {
    services.bob-website = {
      enable = mkEnableOption "bob website";
      domain = mkOption {
        type = types.str;
        description = "Domain that the website will be hosted on.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.nginx.virtualHosts.${cfg.domain} = {
      forceSSL = true;
      enableACME = true;
      root = inputs.bob-website.packages.${pkgs.system}.default;
    };
  };
}
