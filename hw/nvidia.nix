{ config, pkgs, lib, ... }:

{
  specialisation = {
    nvidia.configuration = {
      services.xserver.videoDrivers = ["nvidia" "intel"];
      hardware.opengl.enable = true;
      hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
      hardware.nvidia.modesetting.enable = true;
      hardware.nvidia.prime = {
        sync.enable = true;
	nvidiaBusId = "PCI:1:0:0";
	intelBusId = "PCI:0:2:0";
      };
      hardware.opengl.setLdLibraryPath = true;
      environment.sessionVariables.WLR_NO_HARDWARE_CURSORS = "1";

      virtualisation.docker.enableNvidia = lib.mkForce true;
    };
  };
}
