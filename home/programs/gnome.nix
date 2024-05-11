{ pkgs, ... }:
{
  programs.gnome-shell = {
    enable = true;
    extensions = with pkgs.gnomeExtensions; [
      pop-shell
      appindicator
    ];
  };
}
