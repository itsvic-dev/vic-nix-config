{ pkgs, ... }:
{
  systemd.timers."hddbackup" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = false;
      Unit = "hddbackup.service";
    };
  };

  systemd.services."hddbackup" = {
    script = ''
      set -eu
      ${pkgs.rsync}/bin/rsync -a /mnt/hdd/Archives it-vps:/mnt/hdd/HDDBackup/
    '';
    path = [ pkgs.openssh ];
    serviceConfig = {
      Type = "oneshot";
      User = "vic";
    };
  };
}
