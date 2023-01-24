#!/usr/bin/env bash
picom --config "/home/shaun/.config/picom/picom.conf" &
/usr/libexec/polkit-gnome-authentication-agent-1 &
dwmblocks &
sxhkd &
dunst &
nm-applet &
blueman-applet &
~/.fehbg &
#autorandr --change &
