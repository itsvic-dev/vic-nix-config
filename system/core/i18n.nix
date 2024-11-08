{ config, ... }:
{
  time.timeZone = "Europe/Warsaw";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "pl_PL.UTF-8";
    };
  };
}
