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
      enableUpdateCheck = false;

      extensions = with pkgs.vscode-extensions; [
        # Python
        ms-python.python
        ms-python.black-formatter
        ms-python.vscode-pylance

        # C/C++
        llvm-vs-code-extensions.vscode-clangd
        twxs.cmake
        ms-vscode.cmake-tools

        # Nix
        bbenoist.nix
        brettm12345.nixfmt-vscode

        # Node.js/Web
        dbaeumer.vscode-eslint
        esbenp.prettier-vscode
        vue.volar
        bradlc.vscode-tailwindcss
      ];

      userSettings =
        let
          prettier = {
            "editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
        in
        {
          "editor.tabSize" = 2;
          "editor.formatOnSave" = true;

          "[vue]" = prettier;
          "[typescript]" = prettier;
          "[typescriptreact]" = prettier;

          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;

          "php.validate.executablePath" = "${pkgs.php}/bin/php";
        };
    };
  };
}
