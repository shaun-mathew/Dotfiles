# Added by Toolbox App
export PATH="$PATH:/home/shaun/.local/share/JetBrains/Toolbox/scripts"
export PATH="$PATH:/home/shaun/.nix-profile/bin"


# xrandr --output eDP-1-1 --auto --primary
# if [ "$XDG_SESSION_TYPE" != "wayland" ]; then
# fi

# Speedy keys
xset r rate 210 40
xsetroot -cursor_name left_ptr

# XDG Paths
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

export EDITOR="nvim"
export TERMINAL="kitty"
export BROWSER="firefox"

xrdb ~/.Xresources
export ZDOTDIR=$HOME/.config/zsh

. "$HOME/.cargo/env"
