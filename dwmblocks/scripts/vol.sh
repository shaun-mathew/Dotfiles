#!/bin/sh
isOn=$(awk -F"[][]" '/Left:/ { print $4 }' <(amixer sget Master))
if [ "$isOn" = "off" ]; then
  echo "off"
else
  awk -F"[][]" '/Left:/ { print $2 }' <(amixer sget Master)
fi
