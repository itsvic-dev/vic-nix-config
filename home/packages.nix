{
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = osConfig.vic-nix;
in
{
  home.packages =
    with pkgs;
    [
      git
      _7zz
      nix-output-monitor
      wget
      mtr
    ]
    ++ lib.optionals cfg.desktop.enable (
      [ qbittorrent ]
      ++ lib.optionals pkgs.stdenv.isLinux [
        pavucontrol
        telegram-desktop
        (vesktop.override { withSystemVencord = false; })
        thunderbird
        # (nixpkgs-gimp-master.legacyPackages.${pkgs.stdenv.hostPlatform.system}.gimp)
        obs-studio
        mission-center
      ]
      ++ lib.optionals cfg.desktop.forGaming [ wineWowPackages.stagingFull ]
      ++ lib.optionals cfg.desktop.forDev [
        nodejs
        gcc
        clang-tools
        python3
        httpie
      ]
    )
    ++ cfg.software.extraPackages;
}
