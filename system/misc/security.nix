{ config, lib, ... }:
let
  cfg = config.vic-nix.desktop;
in
{
  config = lib.mkIf cfg.enable {
    # desktop role devices are considered to be machines with lesser security,
    # so we allow wheel group users to execute sudo passwordlessly on these
    # users are immutable anyway so
    security.sudo.wheelNeedsPassword = false;
  };
}
