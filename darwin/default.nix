inputs@{ nixpkgs, nix-darwin, home-manager, nix-rosetta-builder, ... }:
let
  importAllFromFolder = folder:
    let
      toImport = name: value: folder + ("/" + name);
      imports = nixpkgs.lib.mapAttrsToList toImport (builtins.readDir folder);
    in imports;

  common = nixpkgs.lib.lists.flatten [
    ./core
    ../system/options.nix
    ../home

    (importAllFromFolder ./programs)

    home-manager.darwinModules.home-manager
  ];
in
{
  "Victors-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    modules = common ++ [
      nix-rosetta-builder.darwinModules.default
      {
        # nix.linux-builder.enable = true;
        nix-rosetta-builder.onDemand = true;
      }

      ./machines/mbp
    ];
    specialArgs = { inherit inputs; };
  };
}
