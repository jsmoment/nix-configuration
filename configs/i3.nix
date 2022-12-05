{ lib, pkgs, config, ... }:
let
	startpolybar = pkgs.writeShellScript "startpolybar" ''#!/usr/bin/env sh
		pkill polybar
		while pgrep -x polybar >/dev/null; do sleep1; done
    polybar bar &'';
  togglepicom = pkgs.writeShellScript "togglepicom" ''#!/usr/bin/env bash
  if pgrep -x "picom" > /dev/null
  then
    pkill picom
  else
    picom -b
  fi'';
  mod = "Mod1";
  super = "Mod4";
  term = "kitty";
  exec = "exec --no-startup-id";
  ws1 = "1"; ws2 = "2"; ws3 = "3"; ws4 = "4"; ws5 = "5"; ws6 = "6"; ws7 = "7"; ws8 = "8"; ws9 = "9"; ws10 = "10";

  execAlwaysList = [
    "autotiling"
    "${startpolybar}"
    "dispwin -I ~/.config/nixpkgs/icc/GB2470HSU.icm"
  ];
  execList = [
    "xss-lock --transfer-sleep-lock -- betterlockscreen -l dimblur -- --nofork"
    "nitrogen --restore"
    "flameshot"
    "picom"
    "discord"
    "firefox"
    "kitty"
    ];
in

{
  #services.picom.enable = true;
  xsession.enable = true;
  xsession.windowManager.i3 = {
    enable = true;
    package = pkgs.i3-gaps;
    config = {
      defaultWorkspace = "workspace number 1";
      assigns = {
        ${ws2} = [{ class = "firefox"; }];
        ${ws3} = [{ class = "discord"; }];
        ${ws6} = [{ class = "KeePassXC"; }];
        ${ws7} = [{ class = "Steam"; }];
      };
    startup = []
    ++
    builtins.map ( command:
      {
        command = command;
        always = true;
        notification = false;
      }
    ) execAlwaysList
    ++
    builtins.map ( command:
      {
        command = command;
        notification = false;
      }
    ) execList;
      bars = [];
      fonts = {
        names = [ "Liga SFMono Nerd Font" ];
        style = "Regular";
        size = 11.0;
      };
      gaps = {
        inner = 6;
        outer = 6;
      };
      window.border = 0;
      floating.border = 0;
      modifier = "${mod}";
      terminal = "${term}";
      keybindings = lib.mkOptionDefault {
        "${super}+Shift+s" = "${exec} flameshot gui";
        "Print" = "${exec} flameshot full --clipboard";
        "${super}+l" = "${exec} betterlockscreen -l dimblur";
        "${mod}+c" = "${exec} ${togglepicom}";
        "${super}+${mod}+p" = "${exec} shutdown -P --no-wall now";
        "${super}+${mod}+o" = "${exec} shutdown -r --no-wall now";
        "${mod}+Return" = "${exec} ${term}";
        "${mod}+d" = "${exec} \"rofi -modi drun,run -show drun\"";
        "${mod}+w" = "${exec} echo This line is just here to unbind mod+w";
        "${super}+${mod}+i" = "${exec} sudo virsh start win10";
        "XF86TouchpadOff" = "${exec} kitty";
      };
    };
    extraConfig = ''
      for_window [class="^.*"] border pixel 0
      '';
  };
}
