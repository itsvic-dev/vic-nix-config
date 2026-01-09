inputs@{
  nixpkgs,
  home-manager,
  sops-nix,
  disko,
  ...
}:
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
  defineSystem' =
    extraModules: system: hostname:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = rec {
        inherit inputs;
        globalSecretsFile = ../secrets/global.yaml;
        secretsPath = ../secrets/${hostname};
        defaultSecretsFile = "${secretsPath}/default.yaml";
        intranet = import ../intranet { inherit (nixpkgs) lib; };
      };

      modules =
        common
        ++ [
          ./core/boot-${system}.nix
          ./machines/${hostname}
          {
            # define the machine's hostname
            networking.hostName = hostname;
          }
        ]
        ++ extraModules;
    };

  defineSystem = defineSystem' [ ];

  uglyHack = (
    { lib, ... }:
    let
      renamePath = nixpkgs.outPath + "/nixos/modules/rename.nix";
      renameModule = import renamePath { inherit lib; };
      moduleFilter =
        module:
        lib.attrByPath [ "options" "boot" "loader" "raspberryPi" ] null (module {
          config = null;
          options = null;
        }) == null;
    in
    {
      disabledModules = [ renamePath ];
      imports = builtins.filter moduleFilter renameModule.imports;
    }
  );
in
{
  # stage 1 of tree-wide hostname change
  "fra01" = defineSystem "x86_64-linux" "de-fra01";
  "it-vps" = defineSystem "x86_64-linux" "it-mil01";
  "tastypi" = defineSystem' [ uglyHack ] "aarch64-linux" "tastypi";

  "live-rescue" = defineSystem "x86_64-linux" "live-rescue";
}
