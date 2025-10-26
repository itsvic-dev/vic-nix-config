{ config, lib, ... }: {
  time.timeZone = if (!config.vic-nix.server.enable) then "Europe/Warsaw" else "UTC";
  i18n.defaultLocale = "en_US.UTF-8";
}
