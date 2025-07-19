{ osConfig, lib, pkgs, options, ... }:
let cfg = osConfig.vic-nix.desktop;
in {
  config = lib.mkIf (cfg.enable && cfg.forDev) (lib.mkMerge [
    {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false; # hehe

        profiles.default = {
          enableUpdateCheck = false;
          extensions = with pkgs.vscode-extensions;
            [
              ms-vscode-remote.remote-ssh
              bmewburn.vscode-intelephense-client # PHP
              elixir-lsp.vscode-elixir-ls
              vscode-icons-team.vscode-icons # needed by gml-support
              github.vscode-github-actions

              # Python
              ms-python.python
              ms-python.black-formatter
              ms-python.vscode-pylance

              # C/C++
              llvm-vs-code-extensions.vscode-clangd
              twxs.cmake
              ms-vscode.cmake-tools
              mesonbuild.mesonbuild

              # Nix
              bbenoist.nix
              brettm12345.nixfmt-vscode

              # Node.js/Web
              dbaeumer.vscode-eslint
              esbenp.prettier-vscode
              vue.volar
              bradlc.vscode-tailwindcss

              # Rust
              rust-lang.rust-analyzer
              tamasfe.even-better-toml
            ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [{
              name = "gml-support";
              publisher = "liaronce";
              version = "1.7.4";
              sha256 = "sha256-eWBERwmulZ8KO/SpMjusX6WNZpU6ikwSwDsVsxvU8z0=";
            }];

          userSettings = let
            prettier = {
              "editor.defaultFormatter" = "esbenp.prettier-vscode";
            };

            things = map (n: "[${n}]") [
              "vue"
              "javascript"
              "typescript"
              "typescriptreact"
              "css"
            ];

            fullPrettierSetup = lib.genAttrs things (_: prettier);
          in {
            "editor.tabSize" = 2;
            "editor.formatOnSave" = true;

            "git.confirmSync" = false;
            "git.enableSmartCommit" = true;

            "php.validate.executablePath" = "${pkgs.php}/bin/php";
            "mesonbuild.downloadLanguageServer" = false;
            "mesonbuild.languageServerPath" = "${pkgs.mesonlsp}/bin/mesonlsp";
            "cmake.cmakePath" = "${pkgs.cmake}/bin/cmake";

            "rust-analyzer.check.command" = "clippy";
            "rust-analyzer.server.path" = lib.getExe pkgs.rust-analyzer;

            "elixirLS.languageServerOverridePath" = lib.getExe pkgs.elixir-ls;
          } // fullPrettierSetup;
        };
      };

      # required by rust-analyzer
      home.packages = with pkgs; [ clippy ];
    }

    (lib.optionalAttrs (options ? stylix.targets.vscode) {
      stylix.targets.vscode.enable = false;
    })
  ]);
}
