{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ adwaita-qt ];

  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };
}
