{ pkgs, ... }:
{
  programs.steam.enable = pkgs.system == "x86_64-linux";
}
