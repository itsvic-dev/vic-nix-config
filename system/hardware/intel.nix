{ pkgs, ... }:
{
  hardware.opengl.extraPackages = [ pkgs.intel-compute-runtime ];
  hardware.cpu.intel.updateMicrocode = true;
}
