inputs@{ nixpkgs, home-manager, ... }:
let
  importAllFromFolder =
    folder:
    let
      toImport = name: value: folder + ("/" + name);
      imports = nixpkgs.lib.mapAttrsToList toImport (builtins.readDir folder);
    in
    imports;

  # Common modules for all homes.
  common = nixpkgs.lib.lists.flatten [
    ./packages.nix
    (importAllFromFolder ./misc)
    (importAllFromFolder ./programs)
    (importAllFromFolder ./services)
  ];

  # Defines a home configuration with a given system, username and module set.
  defineHome =
    system: username: modules:
    home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules =
        common
        ++ modules
        ++ [
          {
            home.username = username;
            home.homeDirectory = "/home/${username}";
            home.stateVersion = "23.11";
          }
        ];
      extraSpecialArgs = {
        inherit inputs;
      };
    };
in
{
  "vic@e6nix" = defineHome "x86_64-linux" "vic" [ ];
}
