{
  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };

            OS = {
              size = "100%";
              content = {
                type = "luks";
                name = "os_encrypted";
                extraOpenArgs = [ ];
                settings.allowDiscards = true;
                passwordFile = "/tmp/secret.key";

                content = {
                  type = "lvm_pv";
                  vg = "os_pool";
                };
              };
            };
          };
        };
      };
    };

    lvm_vg = {
      os_pool = {
        type = "lvm_vg";
        lvs = {
          swap = {
            size = "24G";
            content = { type = "swap"; };
          };

          data = {
            size = "100%FREE";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/home" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };

                "/persist" = {
                  mountOptions = [ "compress=zstd" "noatime" ];
                  mountpoint = "/persist";
                };

                "/nix" = {
                  mountOptions = [ "compress=zstd" "noatime" ];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };

    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [ "size=25%" "defaults" "mode=755" ];
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
