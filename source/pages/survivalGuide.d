module noro.pages.survivalGuide;

import noro.app;
import noro.types;
import noro.ui.window;
import noro.programs.page;

static const string[] text = [
	"Noro, a text editor made by yeti0904/MESYETI",
	"",
	"Noro has different modes for interacting with the text editor, listed below:",
	"- Standby - Sends all input to the program, and switches to command mode if you",
	"            press CTRL+K",
	"- Command - Interprets key presses as commands (which are listed later on) and",
	"            switches back to standby mode after the command is done",
	"- Window  - Same as command mode, but has commands specific to windows",
	"",
	"Some keybinds will work regardless of the current mode, which are listed below",
	"- CTRL+Q - Exits noro",
	"",
	"Command mode",
	"============",
	"- m     - Switches to window mode",
	"- f     - Maximises the current window",
	"- F     - Fullscreens the current window",
	"- b     - Toggles the border on the current window",
	"- a     - Opens the menu program",
	"- q     - Closes the current window",
	"- (Tab) - Moves the bottom window to the top",
	"",
	"Window mode",
	"===========",
	"- q                    - Switches back to standby mode",
	"- (arrow keys)         - Moves the current window in the direction of the key ",
	"                         by 4 cells",
	"- wasd                 - Resizes the current window in the direction of the key",
	"                         by 4 cells",
	"- shift + (arrow keys) - Moves the current window in the direction of the key by",
	"                         1 cell",
	"- WASD                 - Resizes the current window in the direction of the key",
	"                         by 1 cell"
];

Element[] SurvivalGuidePage() {
	Element[] ret;

	foreach (ref line ; text) {
		ret ~= new TextElement(line);
	}

	return ret;
}
