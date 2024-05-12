{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      brettm12345.nixfmt-vscode
      ms-python.python
      llvm-vs-code-extensions.vscode-clangd
    ];
  };
}
