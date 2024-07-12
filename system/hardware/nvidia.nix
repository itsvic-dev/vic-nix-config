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
    specialisation.nvidia.configuration = {
      # tell nh what spec this is
      environment.etc."specialisation".text = "nvidia";

      services.xserver.videoDrivers = [
        "nvidia"
        "intel"
      ];

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true;
        prime = {
          sync.enable = true;
          nvidiaBusId = "PCI:1:0:0";
          intelBusId = "PCI:0:2:0";
        };
      };

      virtualisation.docker.enableNvidia = true;
      nixpkgs.config.cudaSupport = true;
    };
  };
}
