{
  nixosConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.vic-nix.desktop;
in
{
  config = lib.mkIf (cfg.enable && cfg.forDev) {
    stylix.targets.vscode.enable = false; # the stylix theme for vscode sucks balls
    programs.vscode = {
      enable = true;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        brettm12345.nixfmt-vscode
        ms-python.python
        llvm-vs-code-extensions.vscode-clangd
        vue.volar
        dbaeumer.vscode-eslint
        bradlc.vscode-tailwindcss
        esbenp.prettier-vscode
      ];
    };
  };
}
