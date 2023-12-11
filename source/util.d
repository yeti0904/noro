module noro.util;

import std.uni;
import std.array;
import noro.app;
import noro.types;
import noro.ui.window;
import noro.programs.input;
import noro.terminal.input;
import noro.terminal.buffer;

void CreateInputWindow(string title, string msg, void delegate(string) func) {
	auto app = App.Instance();

	auto window     = new UIWindow(20, 5);
	window.name     = title;
	window.program  = new InputProgram(msg, func);
	window.borderBG = Colour16.White;
	window.borderFG = Colour16.Black;
	
	window.pos = Vec2!ushort(
		cast(ushort) ((app.screen.buffer.GetSize().x / 2) - (window.GetSize().x / 2)),
		cast(ushort) ((app.screen.buffer.GetSize().y / 2) - (window.GetSize().y / 2))
	);

	app.ui.Add(window);
}

KeyPress ParseKey(string str) {
	KeyPress ret;

	foreach (ref part ; str.split!isWhite()) {
		switch (part) {
			case "shift":     ret.mod |= KeyMod.Shift;  break;
			case "alt":       ret.mod |= KeyMod.Alt;    break;
			case "ctrl":      ret.mod |= KeyMod.Ctrl;   break;
			case "tab":       ret.key  = Key.Tab;       break;
			case "backspace": ret.key  = Key.Backspace; break;
			case "up":        ret.key  = Key.Up;        break;
			case "down":      ret.key  = Key.Down;      break;
			case "left":      ret.key  = Key.Left;      break;
			case "right":     ret.key  = Key.Right;     break;
			default: {
				if (part.length == 1) {
					ret.key = part[0];
				}
			}
		}
	}

	return ret;
}
