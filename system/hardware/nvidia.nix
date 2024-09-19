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
    warnings = [
      ''
        You have enabled the Nvidia module specialisation.
        The last time I enabled this, opencv failed to build.
        This may have been fixed in the future, but will require a nixpkgs bump.
        If you do not need it, please disable this and use nouveau instead.
      ''
    ];

    specialisation.nvidia.configuration = {
      # tell nh what spec this is
      environment.etc."specialisation".text = "nvidia";

      services.xserver.videoDrivers = [
        "nvidia"
        "intel"
      ];

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        open = true; # might cause issues idk, haven't used open drivers in a while
        modesetting.enable = true;
        prime = {
          sync.enable = true;
          nvidiaBusId = "PCI:1:0:0";
          intelBusId = "PCI:0:2:0";
        };
      };

      hardware.nvidia-container-toolkit.enable = config.virtualisation.docker.enable;
      nixpkgs.config.cudaSupport = true;
    };
  };
}
