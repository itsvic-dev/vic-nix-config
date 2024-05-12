{ config, pkgs, ... }:
{
  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        efiSupport = true;
        device = "nodev";

        # Catpuccin Mocha theme for Grub
        # theme = pkgs.stdenv.mkDerivation {
        #   pname = "catppuccin-mocha-grub-theme";
        #   version = "0.0.40";
        #   src = pkgs.fetchFromGitHub {
        #     owner = "catppuccin";
        #     repo = "grub";
        #     rev = "803c5df0e83aba61668777bb96d90ab8f6847106";
        #     hash = "sha256-/bSolCta8GCZ4lP0u5NVqYQ9Y3ZooYCNdTwORNvR7M0=";
        #   };
        #   installPhase = "cp -r src/catppuccin-mocha-grub-theme $out";
        # };
      };
    };

    kernelPackages = pkgs.linuxPackages_xanmod_latest;
  };
}
