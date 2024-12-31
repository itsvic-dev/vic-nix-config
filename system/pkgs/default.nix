final: prev: {
  # set of custom pkgs, either written or updated, that havent entered nixpkgs yet
  cider-2 = final.callPackage ./cider-2.nix { };
}
