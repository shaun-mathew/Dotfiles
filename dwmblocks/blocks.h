//Modify this file to change what commands output to your statusbar, and recompile using the make command.
//awk -F"[][]" '/Left:/ { print $2 }' <(amixer sget Master)
static const Block blocks[] = {
	/*Icon*/	/*Command*/		/*Update Interval*/	/*Update Signal*/

  {"^c#89B4FA^    ", "$HOME/Repos/dwmblocks/scripts/vol.sh", 0, 10},
  {"^c#181825^^b#181825^  ", "", 0, 0},
  {"^c#181825^^b#A6E3A1^    ", "printf '^b#C1EBBD^ ' && $HOME/Repos/dwmblocks/scripts/battery.sh && echo '% '", 60, 0},
  {"^c#181825^^b#181825^  ", "", 0, 0},
  {"^b#F38BA8^    ", "printf '^b#F7AEC2^ ' && $HOME/Repos/dwmblocks/scripts/wifi.sh && echo ' '", 5, 0},
  {"^c#181825^^b#181825^  ", "", 0, 0},
	{"^b#74C7EC^    ", "printf '^b#9ED8F2^ ' && $HOME/Repos/dwmblocks/scripts/mem.sh && echo ' '",	30,		0},
  {"^c#181825^^b#181825^  ", "", 0, 0},
	{"^b#FAB397^    ", "printf '^b#FCCAAB^ ' && $HOME/Repos/dwmblocks/scripts/date.sh", 5,		0},
};

//sets delimeter between status commands. NULL character ('\0') means no delimeter.
static char delim[] = "\0";
static unsigned int delimLen = 5;
