{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ adwaita-qt ];

  qt = {
    enable = false; # using kde for config now
    platformTheme = "qt5ct";
  };
}
