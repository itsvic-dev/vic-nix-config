{ config, lib, ... }: {
  time.timeZone = lib.mkDefault "Europe/Warsaw";
  i18n.defaultLocale = "en_US.UTF-8";
}
