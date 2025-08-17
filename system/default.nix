inputs@{ nixpkgs, home-manager, sops-nix, disko, ... }:
let
  inherit (import ../misc/lib.nix nixpkgs.lib) importAllFromFolder;

  # Common modules for all systems.
  common = nixpkgs.lib.lists.flatten [
    ./core
    ./options.nix
    ../cachix.nix
    ../home

    (importAllFromFolder ./misc)
    (importAllFromFolder ./programs)
    (importAllFromFolder ./services)
    (importAllFromFolder ./hardware)

    home-manager.nixosModules.default
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
  ];

  # Defines a system with a given architecture and hostname.
  defineSystem = system: hostname:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = rec {
        inherit inputs;
        globalSecretsFile = ../secrets/global.yaml;
        secretsPath = ../secrets/${hostname};
        defaultSecretsFile = "${secretsPath}/default.yaml";
      };

      modules = common ++ [
        ./core/boot-${system}.nix
        ./machines/${hostname}
        {
          # define the machine's hostname
          networking.hostName = hostname;
        }
      ];
    };
in {
  "it-vps" = defineSystem "x86_64-linux" "it-vps";
  "tastypi" = defineSystem "aarch64-linux" "tastypi";
}
