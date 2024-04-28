inputs@{
  nixpkgs,
  kmonad,
  hyprland,
  ...
}:
let
  # Common modules for all systems.
  common = [
    ./core

    kmonad.nixosModules.default
    hyprland.nixosModules.default
  ];

  # Defines an x86_64-linux system with a given hostname and module set.
  defineAMD64System =
    hostname: modules:
    nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
      };

      modules =
        common
        ++ modules
        ++ [
          ./machines/${hostname}.nix
          {
            # define the machine's hostname
            networking.hostName = hostname;
          }
        ];
    };
in
{
  "e6nix" = defineAMD64System "e6nix" [ ];
}
