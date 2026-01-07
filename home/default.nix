{
  lib,
  inputs,
  pkgs,
  ...
}:
let
  inherit (import ../misc/lib.nix lib) importAllFromFolder;

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

  home-manager.extraSpecialArgs = { inherit (inputs) nix-index-database; };

  home-manager.users.vic = {
    imports = common;
    home.homeDirectory = lib.mkForce (if pkgs.stdenv.isDarwin then "/Users/vic" else "/home/vic");
    home.stateVersion = "23.11";
  };
}
