{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.vic-nix.hardware;
in
{
  config = lib.mkIf cfg.nvidia {
    specialisation = {
      nvidia.configuration = {
        # tell nh what spec this is
        environment.etc."specialisation".text = "nvidia";

        services.xserver.videoDrivers = [
          "nvidia"
          "intel"
        ];

        hardware.graphics = {
          enable = true;
          enable32Bit = pkgs.system == "x86_64-linux";
        };

        hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
        hardware.nvidia.modesetting.enable = true;
        hardware.nvidia.prime = {
          sync.enable = true;
          nvidiaBusId = "PCI:1:0:0";
          intelBusId = "PCI:0:2:0";
        };

        virtualisation.docker.enableNvidia = true;
        nixpkgs.config.cudaSupport = true;
      };
    };
  };
}
