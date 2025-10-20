{ pkgs, inputs, modulesPath, ... }: {
  imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];

  vic-nix.noSecrets = true;
  boot.kernelPackages = pkgs.linuxPackages_6_1;

  environment.systemPackages =
    [ inputs.disko.packages.${pkgs.system}.disko-install ];
}
