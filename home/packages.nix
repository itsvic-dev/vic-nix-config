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
    clang-tools
    gimp
    fastfetch
    mpv
    gnome.file-roller
  ];

  nixpkgs.config.allowUnfree = true;
}
