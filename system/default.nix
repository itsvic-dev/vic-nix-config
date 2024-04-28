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

    ./misc
    ./programs
    ./services

    kmonad.nixosModules.default
    hyprland.nixosModules.default
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
  "e6nix" = defineSystem "x86_64-linux" "e6nix" [ ];
}
