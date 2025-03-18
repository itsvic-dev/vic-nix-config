{ nix-index-database, ... }: {
  imports = [ nix-index-database.hmModules.nix-index ];

  programs = {
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
    nix-index-database.comma.enable = true;
  };
}
