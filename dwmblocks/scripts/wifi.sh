#!/bin/sh

out=$(nmcli -t -f active,ssid | grep 'wlo1: connected' | cut -d ' ' -f4-)

if [ -z "$out" ]
then
  printf "Disconnected"
else
  printf "$out"
fi
