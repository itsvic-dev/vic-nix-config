{
  lib,
  nixosConfig,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.vic-nix;
in
{
  home.packages =
    with pkgs;
    lib.mkMerge [
      [
        git
        p7zip

        nix-output-monitor
        fastfetch

        httpie
        wget
      ]
      (lib.mkIf cfg.desktop.enable [
        pavucontrol
        telegram-desktop
        (vesktop.override { withSystemVencord = false; })
        thunderbird
        blender
        gimp
        mpv
        foliate
        qbittorrent
      ])
      (lib.mkIf (cfg.desktop.enable && cfg.desktop.forGaming) [ wineWowPackages.stable ])
      (lib.mkIf (cfg.desktop.enable && cfg.desktop.forDev) [
        nodejs
        corepack
        gcc
        clang-tools
      ])
    ];

  nixpkgs.config.allowUnfree = true;
}
