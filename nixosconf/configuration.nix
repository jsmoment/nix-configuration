# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  nix-gaming = import (builtins.fetchTarball "https://github.com/fufexan/nix-gaming/archive/master.tar.gz");
in

{
  imports = [
    /etc/nixos/hardware-configuration.nix
    /home/js/.config/nixpkgs/fonts.nix
    /home/js/.config/nixpkgs/nix-gaming/modules/pipewireLowLatency.nix
    /home/js/.config/nixpkgs/nixosconf/pci-passthrough.nix
    /home/js/.config/nixpkgs/nixosconf/openvpn.nix
  ];

  # kernel commandline
  boot.kernelParams = [ "quiet" ];
  
  # zen kernel
  boot.kernelPackages = pkgs.linuxPackages_zen;
  
  # ntfs support
  boot.supportedFilesystems = [ "ntfs" ];

  # set up grub 
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 3;
  boot.loader.grub = {
    enable = true;
    useOSProber = false;
    default = "saved";
    efiSupport = true;
    device = "nodev";
  };
  networking.hostName = "nixos"; # Define your hostname.

  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.firewall.enable = false;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  # Install the NVIDIA drivers.
  nixpkgs.config.allowUnfree = true;
  hardware.opengl.enable = true; 
  hardware.opengl.driSupport32Bit = true;
 
  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    
    videoDrivers = [ "nvidia" ];
    libinput = {
	  enable = true;

	# disable mouse acceleration
	mouse = {
		accelProfile = "flat";
	};
    };
    desktopManager = { xterm.enable = false; };

    displayManager.session = [
      {
        manage = "desktop";
	name = "xsession";
	start = ''exec $HOME/.xsession'';
      }
    ];
  };

  # Configure keymap in X11
  services.xserver.layout = "pl";

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.cnijfilter2 ];
  # Enable sound.
  # sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    lowLatency.enable = true;
    
    lowLatency = {
      quantum = 32;
      rate = 48000;
    };
  };

  # Enable OpenTabletDriver
  hardware.opentabletdriver.enable = true;
  hardware.opentabletdriver.daemon.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.js = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ firefox kitty ];
  };

  # Set the default shell to zsh
  users.defaultUserShell = pkgs.zsh;
  
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  environment.systemPackages = with pkgs; [
    wget
    argyllcms
    nix-gaming.packages.x86_64-linux.wine-osu
    (nix-gaming.packages.x86_64-linux.osu-lazer-bin.override {
      pipewire_latency = "32/48000";
    })
  ];

  nixpkgs.overlays = [
    (self: super: {
      discord = (super.discord.overrideAttrs (
        old: rec {
          src = builtins.fetchTarball https://discord.com/api/download/stable?platform=linux&format=tar.gz;
        }
      )).override {
        nss = super.nss_latest;
      };
    })
  ];
  
  # nix-gaming cachix
  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
  };
  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  # Enable zsh
  programs.zsh.enable = true;
  # enable nix-command and flakes
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';
  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

  # font bullshit
  nixpkgs.config.joypixels.acceptLicense = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  # NUR
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
  
  # autorandr
  services.autorandr = {
    enable = true;
    defaultTarget = "normal";
  };

  # run it automatically on startup
  systemd.user.services.boot-autorandr = {
    description = "Autorandr service";
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.autorandr}/bin/autorandr -c";
      Type = "oneshot";
    };
  };

  # gnome-keyring
  services.gnome.gnome-keyring.enable = true;

  # start virtual machine without password
  security.sudo.extraRules = [ 
    { users = [ "js" ];
      commands = [ { command = "/run/current-system/sw/bin/virsh start win10"; options = [ "NOPASSWD" ]; } ]; }
    ];
}

