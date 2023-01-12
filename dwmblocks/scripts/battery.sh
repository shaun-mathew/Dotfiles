#!/bin/sh

get_capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
printf "$get_capacity"
