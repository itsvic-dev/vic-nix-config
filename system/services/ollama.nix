{ config, lib, ... }:
{
  config = lib.mkIf config.services.ollama.enable (
    lib.mkMerge [
      {
        services.ollama.user = "ollama";
        services.ollama.group = "ollama";
        users.users.ollama = {
          isSystemUser = true;
          group = "ollama";
        };
        users.groups.ollama = { };
      }

      # add ollama's data dir to persistence if needed
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [
          {
            directory = config.services.ollama.home;
            user = config.services.ollama.user;
            group = config.services.ollama.group;
            mode = "0700";
          }
        ];
      })
    ]
  );
}
