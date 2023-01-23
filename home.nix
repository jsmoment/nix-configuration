{ config, pkgs, lib, ... }:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  packages = with pkgs; [
    libnma
    openvpn
    gimp
    shotcut
    audacity
    nomacs
    filezilla
    git
    btop
    libreoffice
    xclip
    xsel
    flameshot
    betterlockscreen
    nextcloud-client
    keepassxc
    alsa-utils
    w3m
    dunst
    picom
    autotiling
    rofi
    bat 
    discord
    # configuration
    nitrogen
    lxappearance
    pavucontrol
    autorandr
    pulseaudio
    pcmanfm 
    # games
    prismlauncher
    heroic
    lunar-client
    lutris
    # wine
    winetricks
    wineWowPackages.staging
    gamemode
    mangohud
];

  globalAliases = {
    gc = "nix-collect-garbage";
    hms = "home-manager switch";
  };

  openasar = builtins.fetchurl {
    url = "https://github.com/GooseMod/OpenAsar/releases/download/nightly/app.asar";
  };
in

{
  imports = [ ] ++ builtins.map (x: ./configs + ("/" + x)) (builtins.attrNames(lib.filterAttrs
  (n: v: v == "regular")
  (builtins.readDir ./configs)
));
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "js";
  home.homeDirectory = "/home/js";
  home.packages = packages;

  nixpkgs.config = import ./config.nix;
  
  nixpkgs.overlays = [
    (self: super: {
      discord = (super.discord.overrideAttrs (
        old: rec {
          src = builtins.fetchTarball https://discord.com/api/download/stable?platform=linux&format=tar.gz;
          postInstall = old.postInstall + ''
            rm $out/opt/Discord/resources/app.asar
            cp ${openasar} $out/opt/Discord/resources/app.asar
          '';
        }
      )).override {
        nss = super.nss_latest;
      };
    })
  ];

  # enable easyeffects
  services.easyeffects.enable = true;
  
  # configure kitty
  programs.kitty = {
    enable = true;
    font.name = "MesloLGS NF";
    theme = "Catppuccin-Mocha";
    settings = {
      cursor_shape = "underline";
      enable_audio_bell = false;
      window_padding_width = 10;
    };
  };

  # configure neovim
  programs.neovim = {
    enable = true;
    extraConfig = ''
      let g:catppuccin_falvour = "macchiato"
      set number
      set clipboard=unnamedplus
      set mouse=nvi
      set inccommand=nosplit
      colorscheme catppuccin
    '';
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    plugins = with pkgs.vimPlugins; [
      catppuccin-nvim
      vim-polyglot
    ];
  };

  # install obs
  programs.obs-studio.enable = true;

  # configure mpv
  programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    config = {
      profile = "gpu-hq";
      vo = "gpu";
      gpu-api = "vulkan";
    };
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
