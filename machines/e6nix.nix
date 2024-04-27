# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # Bootloader.
  boot.loader.grub = {
    efiSupport = true;
    device = "nodev";
    theme = pkgs.stdenv.mkDerivation {
      pname = "catppuccin-mocha-grub-theme";
      version = "0.0.40";
      src = pkgs.fetchFromGitHub {
        owner = "catppuccin";
        repo = "grub";
        rev = "803c5df0e83aba61668777bb96d90ab8f6847106";
        hash = "sha256-/bSolCta8GCZ4lP0u5NVqYQ9Y3ZooYCNdTwORNvR7M0=";
      };
      installPhase = "cp -r src/catppuccin-mocha-grub-theme $out";
    };
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmp.useTmpfs = true;

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  # tell Linux to run AppImages with appimage-run
  boot.binfmt.registrations.appimage = {
    wrapInterpreterInShell = false;
    interpreter = "${pkgs.appimage-run}/bin/appimage-run";
    recognitionType = "magic";
    offset = 0;
    mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
    magicOrExtension = ''\x7fELF....AI\x02'';
  };

  networking.hostName = "e6nix"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [
    3000 # Nuxt dev services
    8443 # demo panel wings
  ];

  fileSystems."/mnt/hdd".device = "/dev/disk/by-uuid/9c6c17e9-58c7-4917-8fd9-43dce75e70a4";

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  hardware.bluetooth.enable = true;

  users.groups = {
    uinput = { };
  };

  qt.platformTheme = "qt5ct";
  qt.enable = true;

  #### USERS ####
  users.users.vic = {
    isNormalUser = true;
    description = "vic";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "uinput"
      "adbusers"
      "docker"
      "wireshark"
      "video"
      "render"
      "vboxusers"
    ];
    packages = with pkgs; [
      thunderbird
      vesktop
      telegram-desktop
      hyfetch
      papirus-icon-theme
      adw-gtk3
      vscode
      cmake
      ninja
      python311
      nodejs
      httpie
      sqlite
      pciutils
      ventoy
      gnumake
      yarn
      scrcpy
      gparted
      p7zip
      aria
      gimp
      file
      qbittorrent
      meson
      corepack
      texliveFull
      conda
      gdb
      jq
      qemu
      mangohud
      pipx
      obs-studio
      prismlauncher
      htop
      yt-dlp
      zoxide
      fzf

      # hi hyprland
      blueman
      pavucontrol
      nomacs
      mpv
      ffmpeg

      libreoffice-qt
      hunspell
      hunspellDicts.en_US
      hunspellDicts.pl_PL

      nodePackages.pyright
      typescript
      nodePackages.eslint
    ];
    shell = pkgs.zsh;
  };

  #### PROGRAMS ####
  programs.adb.enable = true;
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
  };
  programs.hyprland.enable = true;
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    flake = "/home/vic/vic-nix-config";
  };
  programs.nix-ld.enable = true;
  programs.steam.enable = true;
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;
  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
    '';
    promptInit = "";
  };

  #### SERVICES ####
  services.flatpak.enable = true;
  services.gvfs.enable = true;
  services.kmonad = {
    enable = true;
    keyboards = {
      thor300tkl = {
        device = "/dev/input/by-id/usb-SINO_WEALTH_Mechanical_Keyboard-if01-event-kbd";
        defcfg.enable = true;
        defcfg.fallthrough = true;
        config = ''
          (defsrc
            q  w  e  r  t  y  u  i  o  p
            a  s  d  f  g  h  j  k  l  ;
            z  x  c  v  b  n  m
          )

          (deflayer colemak
            q  w  f  p  g  j  l  u  y  ;
            a  r  s  t  d  h  n  e  i  o
            z  x  c  v  b  k  m
          )
        '';
      };
    };
  };
  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
  };
  services.pcscd.enable = true;
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };
  services.redis.servers."" = {
    enable = true;
  };
  services.udisks2.enable = true;
  services.xserver = {
    enable = true;
    displayManager.sddm.enable = true;
    libinput.enable = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  virtualisation.vmware.host.enable = true;
  virtualisation.docker.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.opengl.driSupport = true;
  hardware.opengl.extraPackages = with pkgs; [
    intel-media-driver
    vaapiVdpau
    libvdpau-va-gl
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    gcc
    (chromium.override { commandLineArgs = "--enable-wayland-ime"; })
    docker-compose
    rsync
    adwaita-qt
    python311
    pkgsi686Linux.gperftools
  ];

  services.udev.extraRules = ''
    # KMonad user access to /dev/uinput
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"

    # PSMoveAPI
    # hidraw interface: Bluetooth (=0005), PS Move Motion Controller (=054c:03d5)
    SUBSYSTEM=="hidraw", KERNELS=="0005:054C:03D5.*", MODE="0666"

    # hidraw interface: USB (=0003), PS Move Motion Controller (=054c:03d5)
    SUBSYSTEM=="hidraw", KERNELS=="0003:054C:03D5.*", MODE="0666"

    #hidraw interface: Bluetooth (=0005), PS4 Move Motion Controller, CECH-ZCM2 (=054c:0c5e)
    SUBSYSTEM=="hidraw", KERNELS=="0005:054C:0C5E.*", MODE="0666"

    # hidraw interface: USB (=0003), PS4 Move Motion Controller, CECH-ZCM2 (=054c:0c5e)
    SUBSYSTEM=="hidraw", KERNELS=="0003:054C:0C5E.*", MODE="0666"

    # libusb interface: obsolete (we use hidraw for everything now)
    #SUBSYSTEM=="usb", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="03d5", MODE="0666"
  '';

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    inter
    jetbrains-mono
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];
  fonts.fontconfig = {
    defaultFonts = {
      serif = [
        "Noto Serif"
        "Noto Serif CJK JP"
        "Noto Color Emoji"
      ];
      sansSerif = [
        "Inter"
        "Noto Sans"
        "Noto Sans CJK JP"
        "Noto Color Emoji"
      ];
      monospace = [
        "JetBrains Mono"
        "Noto Sans CJK JP"
        "Noto Color Emoji"
      ];
      emoji = [ "Noto Color Emoji" ];
    };
  };

  powerManagement.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
