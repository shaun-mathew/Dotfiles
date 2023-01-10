#!/bin/bash

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar -c ~/.config/polybar/config.ini mybar &

# for m in $(polybar --list-monitors | cut -d":" -f1); do
#     MONITOR=$m polybar -c ~/.config/polybar/config.ini mybar &
#     echo "$!,$m" > /tmp/polybars
# done
#
