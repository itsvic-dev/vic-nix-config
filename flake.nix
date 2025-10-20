{
  description = "vic's NixOS flake";

  inputs = {
    # --- CORE STUFF ---
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-rosetta-builder = {
      url = "github:cpick/nix-rosetta-builder";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = { url = "github:nix-community/impermanence"; };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- EXTRA SOFTWARE ---
    # nixpkgs-gimp-master.url = "github:jtojnar/nixpkgs/gimp-meson";

    # --- MACHINE-SPECIFIC SOFTWARE ---

    # it-vps
    bob = {
      url = "github:bob-discord-bot/bob";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # tastypi
    bob-website = {
      url = "github:bob-discord-bot/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ticket-bot = {
      url = "github:itsvic-dev/comms-tickets";
      flake = false;
    };

    vncpy = {
      url = "github:itsvic-dev/vncpy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    oxibridge = {
      url = "github:itsvic-dev/oxibridge";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, disko, ... }:
    let
      defineShell = system:
        let
          pkgs = import nixpkgs { inherit system; };
          deployOn = pkgs.callPackage ./misc/deploy.nix { };
        in with pkgs;
        mkShell {
          buildInputs = [ sops age deployOn ] ++ lib.optionals (stdenv.isLinux)
            [ disko.packages.${system}.disko ];
        };

    in {
      nixosConfigurations = import ./system inputs;
      darwinConfigurations = import ./darwin inputs;

      devShells = {
        x86_64-linux.default = defineShell "x86_64-linux";
        aarch64-linux.default = defineShell "aarch64-linux";
        aarch64-darwin.default = defineShell "aarch64-darwin";
      };

      hydraJobs = nixpkgs.lib.mapAttrs (name: value:
        value.config.system.build.${
          if (name == "live-rescue") then "isoImage" else "toplevel"
        }) self.nixosConfigurations;
    };
}
