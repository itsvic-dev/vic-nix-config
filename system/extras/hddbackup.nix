{ pkgs, ... }:
{
  fileSystems."/mnt/hdd".device = "/dev/disk/by-uuid/9c6c17e9-58c7-4917-8fd9-43dce75e70a4";

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
