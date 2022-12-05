{config, pkgs, lib, ...}:

let
  mkZshPlugin = { pkg, file ? "${pkg.pname}.plugin.zsh" }: rec {
    name = pkg.pname;
    src = pkg.src;
    inherit file;
  };
in

{
  programs.zsh = {
    enable = true;
    
    shellAliases = {
      openboard = "nix-shell -p openboard --run 'OpenBoard'";
      ll = "ls -l --color";
      ls = "ls --color";
      hms = "home-manager switch";
      update = "nix-channel --update; sudo nix-channel --update; sudo nixos-rebuild switch -I $HOME/.config/nixpkgs/nixosconf/configuration.nix; home-manager switch";
      nix-clean = "nix-collect-garbage -d; sudo nix-collect-garbage -d";
      nos = "sudo nixos-rebuild switch -I $HOME/.config/nixpkgs/nixosconf/configuration.nix";
      nixs = "nix search nixpkgs";
      icat = "kitty +kitten icat";
      ssh = "kitty +kitten ssh";
      cat = "bat";
    };
    initExtraFirst = ''
      PATH=~/.local/bin:$PATH
      source ~/.zsh/catppuccin-zsh-syntax-highlighting.zsh
    '';
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ./p10k;
        file = "p10k.zsh";
      }
      (mkZshPlugin { pkg = pkgs.zsh-syntax-highlighting; })
      (mkZshPlugin { pkg = pkgs.zsh-autosuggestions; })
    ];
  };
}
