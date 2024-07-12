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
    hardware = {
      cpu.intel.updateMicrocode = true;
      graphics.extraPackages = with pkgs; [
        intel-compute-runtime
        intel-media-driver
      ];
    };
    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  };
}
