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
      wget
    ]
    ++ lib.optionals cfg.desktop.enable (
      [
        pavucontrol
        telegram-desktop
        (vesktop.override { withSystemVencord = false; })
        thunderbird
        gimp
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
        httpie
      ]
    );

  nixpkgs.config.allowUnfree = true;
}
