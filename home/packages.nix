{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    nix-output-monitor
    pavucontrol
    telegram-desktop
    (vesktop.override { withSystemVencord = false; })
    clang-tools
    gimp
    fastfetch
    mpv
    httpie
    wget
    p7zip
    thunderbird
    nodejs
    corepack
    blender
    gcc
    foliate
    qbittorrent
    wineWowPackages.stable
  ];

  nixpkgs.config.allowUnfree = true;
}
