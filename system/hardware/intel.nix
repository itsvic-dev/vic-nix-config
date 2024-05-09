{ pkgs, ... }:
{
  hardware.opengl.extraPackages = [ pkgs.intel-compute-runtime ];
}
