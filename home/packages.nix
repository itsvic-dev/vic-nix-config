{ lib, osConfig, pkgs, nixpkgs-gimp-master, ... }:
let cfg = osConfig.vic-nix;
in {
  home.packages = with pkgs;
    [ git _7zz nix-output-monitor wget ] ++ lib.optionals cfg.desktop.enable ([
      pavucontrol
      telegram-desktop
      (vesktop.override { withSystemVencord = false; })
      thunderbird
      (nixpkgs-gimp-master.legacyPackages.${pkgs.system}.gimp)
      qbittorrent
      obs-studio
      mission-center
    ] ++ lib.optionals cfg.desktop.forGaming [ wineWowPackages.stagingFull ]
      ++ lib.optionals cfg.desktop.forDev [
        nodejs
        corepack
        gcc
        clang-tools
        python3
        httpie
      ]) ++ cfg.software.extraPackages;
}
