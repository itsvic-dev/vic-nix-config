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
    httpie
    wget
    p7zip
  ];

  nixpkgs.config.allowUnfree = true;
}
