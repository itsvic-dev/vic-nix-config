{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.vic-nix.hardware;
in
{
  config = lib.mkIf cfg.intel {
    hardware.graphics.extraPackages = [ pkgs.intel-compute-runtime ];
    hardware.cpu.intel.updateMicrocode = true;
  };
}
