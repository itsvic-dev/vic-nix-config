{ lib, inputs, ... }:
let
  importAllFromFolder =
    folder:
    let
      toImport = name: value: folder + ("/" + name);
      imports = lib.mapAttrsToList toImport (builtins.readDir folder);
    in
    imports;

  # Common modules for all homes.
  common = lib.lists.flatten [
    ./packages.nix
    (importAllFromFolder ./misc)
    (importAllFromFolder ./programs)
    (importAllFromFolder ./services)
  ];
in
{
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;

  home-manager.extraSpecialArgs = {
    inherit (inputs) nix-index-database nixpkgs-gimp-master;
  };

  home-manager.users.vic = {
    imports = common;
    home.stateVersion = "23.11";
  };
}
