{ config, ... }:
{
  time.timeZone = "Europe/Warsaw";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_TIME = "pl_PL.UTF-8";
    };
  };

  # NOTE: idk how well this will play with KMonad in userspace,
  # i just want it working in initrd for now.
  # i hardly use the TTY on desktop anyway, and I can just bring
  # the keyboard out of NKRO mode so KMonad doesn't affect it.
  console.keyMap = if (config.services.kmonad.enable == true) then "mod-dh-ansi-us" else "pl2";
}
