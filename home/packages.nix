{ pkgs, ... }:
{
  home.packages = with pkgs; [
    blueman
    git
    nix-output-monitor
    pavucontrol
    telegram-desktop
    vesktop
	vscode
  ];

  nixpkgs.config.allowUnfree = true;
}