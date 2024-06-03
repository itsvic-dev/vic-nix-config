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
        nix-output-monitor
        clang-tools
        fastfetch
        httpie
        wget
        p7zip
        nodejs
        corepack
        gcc
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
    ];

  nixpkgs.config.allowUnfree = true;
}
