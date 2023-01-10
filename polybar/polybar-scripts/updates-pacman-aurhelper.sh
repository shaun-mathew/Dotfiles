
#!/bin/sh

while pgrep checkupdates >/dev/null; do sleep 1; done
if ! updates_arch="$(checkupdates 2>/dev/null | wc -l)"; then
    updates_arch=0
fi

if ! updates_aur=$(paru -Qum 2> /dev/null | wc -l); then
    updates_aur=0
fi

updates=$((updates_arch + updates_aur))

echo " $updates" updates
