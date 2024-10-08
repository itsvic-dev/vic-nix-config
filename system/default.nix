inputs@{
  nixpkgs,
  kmonad,
  home-manager,
  stylix,
  sops-nix,
  disko,
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
    ./options.nix
    ../cachix.nix
    ../home
    kmonad.nixosModules.default
    home-manager.nixosModules.default
    stylix.nixosModules.stylix
    sops-nix.nixosModules.sops
    disko.nixosModules.disko
    (importAllFromFolder ./misc)
    (importAllFromFolder ./programs)
    (importAllFromFolder ./services)
    (importAllFromFolder ./hardware)
  ];

  # Defines a system with a given architecture and hostname.
  defineSystem =
    system: hostname:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
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
in
{
  "e6nix" = defineSystem "x86_64-linux" "e6nix";
  "it-vps" = defineSystem "x86_64-linux" "it-vps";
  "tastypi" = defineSystem "aarch64-linux" "tastypi";
}
