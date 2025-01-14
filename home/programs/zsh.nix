{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    initExtra = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
  };

  programs.zoxide = {
    enable = true;
    options = [
      "--cmd"
      "cd"
    ];
  };
}
