{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      inter
      jetbrains-mono
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    fontconfig = {
      defaultFonts = {
        serif = [
          "Noto Serif"
          "Noto Serif CJK JP"
          "Noto Color Emoji"
        ];
        sansSerif = [
          "Inter"
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
}
