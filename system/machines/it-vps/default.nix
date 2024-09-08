{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  bob = inputs.bob.packages.x86_64-linux.default;
in
{
  imports = [
    ./hardware.nix
    ./ptero.nix
    ./transmission.nix
    ./staticnetwork.nix
    ./cloudflared.nix
  ];

  vic-nix = {
    server = {
      enable = true;
    };
    software = {
      docker = true;
    };
  };

  services.qemuGuest.enable = true;
  services.netdata.enable = true;

  systemd.services."comms-tickets" = {
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/home/vic/comms-tickets/venv/bin/python /home/vic/comms-tickets/main.py";
      User = "vic";
      Restart = "always";
      WorkingDirectory = "/home/vic/comms-tickets";
    };
  };

  systemd.services."bob" = {
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${bob}/bin/bob";
      User = "vic";
      Restart = "always";
      WorkingDirectory = "/mnt/hdd/bob";
    };
  };

  systemd.services."vyltrix-bot" = {
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "/home/vic/vyltrix/bot/venv/bin/python main.py";
      User = "vic";
      Restart = "always";
      WorkingDirectory = "/home/vic/vyltrix/bot";
    };
  };
}
