{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    oh-my-zsh = {
      enable = true;
      theme = "nicoulaj";
    };
  };

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
  };

  programs.bat.enable = true;
}
