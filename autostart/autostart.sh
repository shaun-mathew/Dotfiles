#!/usr/bin/env bash
~/.fehbg &
picom --config "/home/shaun/.config/picom/picom.conf" &
/usr/libexec/polkit-gnome-authentication-agent-1 &
dwmblocks &
sxhkd &
dunst &
nm-applet &
blueman-applet &
