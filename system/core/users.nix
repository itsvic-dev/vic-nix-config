{
  users.groups = {
    uinput = { };
  };
  users.users.vic = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "uinput"
      "adbusers"
      "docker"
      "wireshark"
      "video"
      "render"
    ];
  };
}
