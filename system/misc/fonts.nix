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
        adwaita-fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        # inter
        # jetbrains-mono
      ];
      fontconfig = {
        defaultFonts = {
          serif = [
            "Noto Serif"
            "Noto Serif CJK JP"
            "Noto Color Emoji"
          ];
          sansSerif = [
            "Adwaita Sans"
            # "Inter Variable"
            "Noto Sans"
            "Noto Sans CJK JP"
            "Noto Color Emoji"
          ];
          monospace = [
            "Adwaita Mono"
            # "JetBrains Mono"
            "Noto Sans CJK JP"
            "Noto Color Emoji"
          ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
