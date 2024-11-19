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
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
        intel-compute-runtime
        vpl-gpu-rt
        intel-media-sdk
      ];
    };
    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
  };
}
