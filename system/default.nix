inputs@{
  nixpkgs,
  kmonad,
  hyprland,
  ...
}:
let
  importAllFromFolder =
    folder:
    let
      toImport = name: value: folder + ("/" + name);
      imports = nixpkgs.lib.mapAttrsToList toImport (builtins.readDir folder);
    in
    imports;

  # Common modules for all systems.
  common = nixpkgs.lib.lists.flatten [
    ./core
    kmonad.nixosModules.default
    (importAllFromFolder ./misc)
    (importAllFromFolder ./programs)
    (importAllFromFolder ./services)
  ];

  # Defines a system with a given hostname and module set.
  defineSystem =
    system: hostname: modules:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
      };

      modules =
        common
        ++ modules
        ++ [
          ./core/boot-${system}.nix
          ./machines/${hostname}.nix
          {
            # define the machine's hostname
            networking.hostName = hostname;
          }
        ];
    };
in
{
  "e6nix" = defineSystem "x86_64-linux" "e6nix" [
    ./hardware/laptop.nix
    ./hardware/nvidia.nix
  ];
}
