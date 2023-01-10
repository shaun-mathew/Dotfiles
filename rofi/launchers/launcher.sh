#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

# Available Styles
#. "${HOME}/.cache/wal/colors.sh"

theme="style_7"
dir="$HOME/.config/rofi/launchers"

# dark
ALPHA="#00000000"
BG="#181825"cc
FG="#FFFFFFff"
SELECT="#000000ff"

ACCENT="#cba6f7"ff


# overwrite colors file
cat > $dir/colors.rasi <<- EOF
	/* colors */

	* {
	  al:  $ALPHA;
	  bg:  $BG;
	  se:  $SELECT;
	  fg:  $FG;
	  ac:  $ACCENT;
	}
EOF

rofi -no-lazy-grab -show drun -modi drun -theme "$HOME/.config/rofi/launchers/style.rasi"
