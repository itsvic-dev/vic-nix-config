{ pkgs, ... }:
{
  home.packages = with pkgs; [
    git
    nix-output-monitor
    pavucontrol
    telegram-desktop
    vesktop
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
  ];

  nixpkgs.config.allowUnfree = true;
}
