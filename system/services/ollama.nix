{ config, lib, ... }: {
  config = lib.mkIf config.services.ollama.enable (lib.mkMerge [
    {
      services.ollama.user = "ollama";
      services.ollama.group = "ollama";
      # the ollama nixos module sets DynamicUser even with the user set by us. Fucking Stupid
      systemd.services.ollama.serviceConfig.DynamicUser = lib.mkForce false;
    }

    # add ollama's data dir to persistence if needed
    (lib.mkIf config.vic-nix.tmpfsAsRoot {
      environment.persistence."/persist".directories = [{
        directory = config.services.ollama.home;
        user = config.services.ollama.user;
        group = config.services.ollama.group;
        mode = "0700";
      }];
    })
  ]);
}
