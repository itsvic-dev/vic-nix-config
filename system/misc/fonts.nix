{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.vic-nix.desktop.enable {
    fonts = {
      packages = with pkgs; [
        cantarell-fonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        inter
        jetbrains-mono
      ];
      fontconfig = {
        defaultFonts = {
          serif = [
            "Noto Serif"
            "Noto Serif CJK JP"
            "Noto Color Emoji"
          ];
          sansSerif = [
            "Cantarell"
            "Inter Variable"
            "Noto Sans"
            "Noto Sans CJK JP"
            "Noto Color Emoji"
          ];
          monospace = [
            "JetBrains Mono"
            "Noto Sans CJK JP"
            "Noto Color Emoji"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
