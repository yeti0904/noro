module noro.pages.survivalGuide;

import noro.app;
import noro.types;
import noro.ui.window;
import noro.programs.page;

static const string[] text = [
	"Noro, a text editor made by yeti0904/MESYETI",
	"",
	"Noro has different modes for interacting with the text editor, listed below:",
	"- Standby  - Sends all input to the program, and switches to command mode if you",
	"            press CTRL+K",
	"- Shortcut - Interprets key presses as shortcuts (which are listed later on) and",
	"            switches back to standby mode after the command is done",
	"- Window   - Same as command mode, but has commands specific to windows",
	"",
	"Some keybinds will work regardless of the current mode, which are listed below",
	"- CTRL+Q - Exits noro",
	"",
	"Note: The keybinds documented below are the default noro keybinds, your config",
	"      may differ",
	"Shortcut mode",
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
	"                         by 1 cell",
	"",
	"",
	"Noro allows you to configure different parts of the editor using the autoexec",
	"file located in HOME/.config/noro/autoexec",
	"You may find that this file is already populated with some configuration",
	"Things you can do with it to customise noro are listed below",
	"Shortcuts",
	"=========",
	"You can define shortcuts by using the shortcut command in the file, it works",
	"like this:",
	"    shortcut \"keys\" \"action\"",
	"The actions are just commands, which are documented later",
	"As for the keys you can add any of these:",
	"- ctrl      - control key modifier",
	"- shift     - shift key modifier (only for non-alpha keys)",
	"- alt       - alt key modifier",
	"- up        - up arrow key",
	"- down      - down arrow key",
	"- left      - left arrow key",
	"- right     - right arrow key",
	"- tab       - tab key",
	"- backspace - backspace key",
	"",
	"",
	"Noro has commands which (for now) can only be executed through shortcuts",
	"Here's a list of them with what parameters they take:",
	"- window                - Switches the editor to window mode",
	"- maximise              - Maximises the current window",
	"- fullscreen            - Fullscreens the current window",
	"- border                - Toggles the border on the current window",
	"- menu                  - Opens the program menu",
	"- close                 - Closes the current window",
	"- switch                - Moves the bottom window to the top",
	"- shortcut <keys> <cmd> - Defines a new shortcut with the given keys and command"
];

Element[] SurvivalGuidePage() {
	Element[] ret;

	foreach (ref line ; text) {
		ret ~= new TextElement(line);
	}

	return ret;
}
