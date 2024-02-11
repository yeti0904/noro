module noro.util;

import std.uni;
import std.array;
import std.format;
import std.datetime;
import noro.app;
import noro.theme;
import noro.types;
import noro.program;
import noro.ui.window;
import noro.programs.input;
import noro.terminal.input;
import noro.terminal.buffer;
import noro.programs.selection;

public import core.stdc.errno;
public import core.stdc.stdlib : exit;
public import core.stdc.string : strerror;

void CreateInputWindow(
	Program program, string title, string msg, void delegate(Program, string) func
) {
	auto app = App.Instance();

	auto window         = new UIWindow(30, 7);
	window.name         = title;
	window.program      = new InputProgram(msg, func, program);
	window.borderColour = ThemeColour.Dialog;
	
	window.pos = Vec2!ushort(
		cast(ushort) ((app.screen.buffer.GetSize().x / 2) - (window.GetSize().x / 2)),
		cast(ushort) ((app.screen.buffer.GetSize().y / 2) - (window.GetSize().y / 2))
	);

	app.GetUI().Add(window);
}

void CreateSelectionWindow(
	Program program, string title, string msg, string[] options,
	void delegate(Program, string) func
) {
	auto app = App.Instance();

	auto window         = new UIWindow(30, 7);
	window.name         = title;
	window.program      = new SelectionProgram(msg, options, func, program);
	window.borderColour = ThemeColour.Dialog;
	
	window.pos = Vec2!ushort(
		cast(ushort) ((app.screen.buffer.GetSize().x / 2) - (window.GetSize().x / 2)),
		cast(ushort) ((app.screen.buffer.GetSize().y / 2) - (window.GetSize().y / 2))
	);

	app.GetUI().Add(window);
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

bool IsWordChar(dchar ch) {
	return (ch == '_') || ch.isAlphaNum();
}

string ClockString() {
	auto time = Clock.currTime();

	return format("%.2d:%.2d:%.2d", time.hour, time.minute, time.second);
}

string SizeAsString(ulong size) {
	if (size < 1024) {
		return format("%d B", size);
	}
	else if (size < 1024 * 1024) {
		return format("%d KiB", size / 1024);
	}
	else if (size < 1024 * 1024 * 1024) {
		return format("%d MiB", size / 1024 / 1024);
	}
	else {
		return format("%d GiB", size / 1024 / 1024 / 1024);
	}
}
