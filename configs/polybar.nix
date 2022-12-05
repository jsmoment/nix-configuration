{ lib, pkgs, config, ...}:
let
  polycpu = pkgs.writers.writePython3 "polycpu" { libraries = [ pkgs.python3Packages.psutil ]; }
    ''
      from psutil import cpu_percent
      usage = cpu_percent(interval=1)

      if usage >= 50:
          print("%{F#ccb81f}"f"{usage}%")
      elif usage >= 90:
          print("%{F#cc3e1f}"f"{usage}%")
      else:
          print(f"{usage}%")
    '';
    i3memory = pkgs.writeShellScript "i3memory" ''#!/bin/sh
TYPE="''${BLOCK_INSTANCE:-mem}"

awk -v type=$TYPE '
/^MemTotal:/ {
	mem_total=$2
}
/^MemFree:/ {
	mem_free=$2
}
/^Buffers:/ {
	mem_free+=$2
}
/^Cached:/ {
	mem_free+=$2
}
/^SwapTotal:/ {
	swap_total=$2
}
/^SwapFree:/ {
	swap_free=$2
}
END {
	if (type == "swap") {
		free=swap_free/1024/1024
		used=(swap_total-swap_free)/1024/1024
		total=swap_total/1024/1024
	} else {
		free=mem_free/1024/1024
		used=(mem_total-mem_free)/1024/1024
		total=mem_total/1024/1024
	}
	pct=0
	if (total > 0) {
		pct=used/total*100
	}
	# full text
	printf("%.1fG/%.1fG", used, total)
}
    ' /proc/meminfo
    '';

  i3weather = pkgs.writeShellScript "i3weather" ''#!/bin/sh
# i3block for displaying the current temperature, humidity and precipitation, if wttr.in i unavailable then WEATHER UNAVAILABLE will be displayed

weather=''$(curl -s "wttr.in/Debica?m&format=3")

if [ $(echo "$weather" | grep -E "(Unknown|curl|HTML)" | wc -l) -gt 0 ]; then
    echo "WEATHER UNAVAILABLE"
else
     echo "$weather" | awk '{print $2" "$3}'
#    echo "$weather" | awk '{print $3}'
	fi'';


  colors.background = "#aa1A1826";
  colors.background-alt = "#aa1A1826";
  colors.foreground = "F2CDCD";
  colors.foreground-alt = "F2CDCD";
  colors.highlight = "#96CDFB";
  colors.primary = "#96CDFB";
  colors.alert = "#FAE3B0";
in

{
  services.polybar = {
    enable = true;
    package = pkgs.polybar.override {
      i3Support = true;
      pulseSupport = true;
    };
    script = "polybar bar &";
    extraConfig = ''
[settings]
format-foreground =
format-underline = ${colors.primary}
format-background = ${colors.background-alt}
format-padding = 1
format-overline = #00000000
format-margin = 0
format-offset =
screenchange-reload = true

[global/wm]
margin-top = 0
margin-bottom = 0

[bar/bar]
;monitor = ${env:MONITOR:DisplayPort-0}
;monitor-fallback = ${env:MONITOR:DisplayPort-1}
;monitor-strict = false
;monitor-exact = true
override-redirect = false
wm-restack = i3
enable-ipc = true
fixed-center = false
bottom = false
separator =

width = 100%
height = 32
offset-x = 0
offset-y = 0
radius = 0.0

underline-size = 3
overline-size = 0

background = ${colors.background}
foreground = ${colors.foreground}

module-margin-left = 0
module-margin-right = 1

;font-0 = SF Mono:pixelsize=12;1
font-0 = Liga SFMono Nerd Font:pixelsize=12;1
font-4 = Noto Color Emoji:fontformat=truetype:scale=11:antialias=false;1
font-1 = FontAwesome6Free:style=Solid:size=11;1
font-2 = FontAwesome6Free:style=Regular:size=11;1
font-3 = FontAwesome6Brands:style=Regular:size=11;1

modules-left = i3 xwindow
modules-right = volume cpu-usage memory weather time

tray-position = right
tray-padding = 1
tray-margin = 100
tray-background = ${colors.background-alt}
tray-offset-x = 0
tray-offset-y = 0
tray-scale = 1.0

cursor-click = pointer
cursor-scroll = default

scroll-up = i3wm-wsnext
scroll-down = i3wm-wsprev

[module/xwindow]
type = internal/xwindow
label = %title:0:30:...%

format-underline = ${colors.background}
format-background = ${colors.background}

[module/i3]
type = internal/i3
format = <label-state> <label-mode>
index-sort = true
wrapping-scroll = false

enable-scroll = true
label-mode-padding = 1

label-focused = %index%
label-focused-background = ${colors.background}
label-focused-underline = ${colors.primary}
label-focused-padding = 1

label-unfocused = %index%
label-unfocused-padding = 1

label-occupied = %index%
label-occupied-padding = 1

label-urgent = %index%!
label-urgent-underline = ${colors.alert}
label-urgent-padding = 1

label-empty = %index%
label-empty-foreground = ${colors.foreground-alt}
label-empty-padding = 1

label-visible = %index%
label-visible-padding = 1


format-underline = ${colors.background}
format-background = ${colors.background}

; Separator in between workspaces

[module/memory]
type = custom/script
exec = ${i3memory}
label = "%output%"
interval = 5
format-prefix = " "

[module/cpu-usage]
type = custom/script
exec = ${polycpu}
label = "%output%"
interval = 1
format-prefix = " "

[module/weather]
type = custom/script
exec = ${i3weather}
label = "%output%"
click-left = kitty -e w3m wttr.in/Debica?m &
interval = 1800

[module/volume]
type = internal/pulseaudio

master-soundcard = default
speaker-soundcard = default
headphone-soundcard = default

format-volume = <label-volume> <bar-volume>
label-volume = VOL %percentage%%
label-volume-foreground = ${colors.foreground}

label-muted = 🔇 muted
label-muted-foreground = #666

bar-volume-width = 10
bar-volume-foreground-0 = #55aa55
bar-volume-foreground-1 = #55aa55
bar-volume-foreground-2 = #55aa55
bar-volume-foreground-3 = #55aa55
bar-volume-foreground-4 = #55aa55
bar-volume-foreground-5 = #f5a70a
bar-volume-foreground-6 = #ff5555
bar-volume-gradient = false
bar-volume-indicator = |
bar-volume-indicator-font = 2
bar-volume-fill = ─
bar-volume-fill-font = 2
bar-volume-empty = ─
bar-volume-empty-font = 2
bar-volume-empty-foreground = ${colors.foreground-alt}

[module/time]
type = custom/script
exec = date '+%d/%m/%Y %I:%M:%S %p'
click-left = thunderbird &
label = " %output%"
interval = 1
  '';
  };
}
