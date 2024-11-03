{
  lib,
  nixosConfig,
  pkgs,
  inputs,
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
      wget
    ]
    ++ lib.optionals cfg.desktop.enable (
      [
        pavucontrol
        telegram-desktop
        (vesktop.override { withSystemVencord = false; })
        thunderbird
        (inputs.nixpkgs-gimp-master.legacyPackages.${pkgs.system}.gimp)
        qbittorrent
        obs-studio
        mission-center
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
