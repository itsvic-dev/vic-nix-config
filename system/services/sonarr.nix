{ config, lib, ... }:
{
  config = lib.mkIf config.services.sonarr.enable (
    lib.mkMerge [
      # add sonarr's data dir to persistence if needed
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [
          {
            directory = config.services.sonarr.dataDir;
            user = config.services.sonarr.user;
            group = config.services.sonarr.group;
            mode = "0700";
          }
        ];
      })

      {
        # sonarr won't build without these for now. lovely
        nixpkgs.config.permittedInsecurePackages = [
          "aspnetcore-runtime-wrapped-6.0.36"
          "aspnetcore-runtime-6.0.36"
          "dotnet-sdk-wrapped-6.0.428"
          "dotnet-sdk-6.0.428"
        ];
      }
    ]
  );
}
