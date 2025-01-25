{ config, lib, ... }:
{
  config = lib.mkIf config.services.ollama.enable (
    lib.mkMerge [
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
