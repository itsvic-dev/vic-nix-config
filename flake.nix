{
  description = "vic's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vncpy = {
      url = "github:itsvic-dev/vncpy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bob-website = {
      url = "github:bob-discord-bot/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, ... }:
    {
      nixosConfigurations = import ./system inputs;

      devShells.x86_64-linux.default =
        let
          pkgs = import nixpkgs { system = "x86_64-linux"; };

          deployOn = pkgs.writeShellApplication {
            name = "deploy";
            runtimeInputs = with pkgs; [
              nix-output-monitor
              nix
              openssh
            ];
            text = ''
              set -e
              HOST="$2"
              OPERATION="$1"

              # build the system configuration
              nom build -j0 -o /tmp/vic-nix-rebuild .\#nixosConfigurations."$HOST".config.system.build.toplevel

              # copy it to the target host
              DERIVATION="$(readlink /tmp/vic-nix-rebuild)"
              nix-copy-closure --to "$HOST" "$DERIVATION"
              rm /tmp/vic-nix-rebuild

              # and finally, deploy it on the host
              ssh "$HOST" -- sudo "$DERIVATION"/bin/switch-to-configuration "$OPERATION"
            '';
          };
        in
        with pkgs;
        mkShell {
          buildInputs = [
            sops
            age
            deployOn
          ];
        };
    };
}
