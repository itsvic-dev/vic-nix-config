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
    [
      git
      p7zip

      nix-output-monitor
      fastfetch

      httpie
      wget
    ]
    ++ lib.optionals cfg.desktop.enable (
      [
        pavucontrol
        telegram-desktop
        (vesktop.override { withSystemVencord = false; })
        thunderbird
        blender
        gimp
        foliate
        qbittorrent
        obs-studio
      ]
      ++ lib.optionals cfg.desktop.forGaming [ wineWowPackages.stable ]
      ++ lib.optionals cfg.desktop.forDev [
        nodejs
        corepack
        gcc
        clang-tools
        python3
      ]
    );

  nixpkgs.config.allowUnfree = true;
}
