inputs@{ nixpkgs, nix-darwin, nix-rosetta-builder, ... }:
let
  inherit (import ../misc/lib.nix nixpkgs.lib) importAllFromFolder;

  common = nixpkgs.lib.lists.flatten [
    ./core
    ../system/options.nix
    ../home

    (importAllFromFolder ./programs)

    inputs.home-manager.darwinModules.home-manager
    inputs.sops-nix.darwinModules.sops
  ];
in {
  "Victors-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    modules = common ++ [
      nix-rosetta-builder.darwinModules.default
      {
        # When bootstrapping a new machine, enable this first, then rosetta-builder.
        # nix.linux-builder.enable = true;
        nix-rosetta-builder.onDemand = true;
      }

      ./machines/mbp
    ];
    specialArgs = {
      inherit inputs;
      # secretsPath = ../secrets/mbp;
      # defaultSecretsFile = "${secretsPath}/default.yaml";
      globalSecretsFile = ../secrets/global.yaml;
    };
  };
}
