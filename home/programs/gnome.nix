{ pkgs, ... }:
{
  programs.gnome-shell = {
    enable = true;
    extensions = with pkgs.gnomeExtensions; [
      { package = pop-shell; }
      { package = appindicator; }
    ];
  };
}
