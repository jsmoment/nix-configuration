{config, pkgs, lib, ...}:
{
fonts.fonts = with pkgs; [
fira-mono
noto-fonts
font-awesome
hanazono
jetbrains-mono
joypixels
roboto
roboto-mono
sarasa-gothic
baekmuk-ttf
cascadia-code
ubuntu_font_family
ttf_bitstream_vera
dejavu_fonts
liberation_ttf
fira-code
nur.repos.rewine.ttf-ms-win10
];

users.users.js.packages = with pkgs; [
catppuccin-gtk
papirus-icon-theme
];
}
