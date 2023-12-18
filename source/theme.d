module noro.theme;

import std.json;
import std.format;
import std.process;
import noro.terminal.buffer;

enum ThemeColour {
	Dialog,
	Window,
	Background,
	TopBar
}

class ThemeException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

class Theme {
	Attr dialog;
	Attr window;
	Attr background;
	Attr topBar;

	this() {
		Default();
	}

	static Colour16[string] GetColourStrings() {
		return [
			"black":         Colour16.Black,
			"red":           Colour16.Red,
			"green":         Colour16.Green,
			"yellow":        Colour16.Yellow,
			"blue":          Colour16.Blue,
			"magenta":       Colour16.Magenta,
			"cyan":          Colour16.Cyan,
			"white":         Colour16.White,
			"default":       Colour16.Default,
			"grey":          Colour16.BrightBlack,
			"brightblack":   Colour16.BrightBlack,
			"brightred":     Colour16.BrightRed,
			"brightgreen":   Colour16.BrightGreen,
			"brightyellow":  Colour16.BrightYellow,
			"brightblue":    Colour16.BrightBlue,
			"brightmagenta": Colour16.BrightMagenta,
			"brightcyan":    Colour16.BrightCyan,
			"brightwhite":   Colour16.BrightWhite
		];
	}

	Attr GetColour(ThemeColour colour) {
		final switch (colour) {
			case ThemeColour.Dialog:     return dialog;
			case ThemeColour.Window:     return window;
			case ThemeColour.Background: return background;
			case ThemeColour.TopBar:     return topBar;
		}
	}

	void Default() {
		window     = Attr.NewColour16(Colour16.White, Colour16.Black);
		dialog     = Attr.NewColour16(Colour16.Black, Colour16.White);
		background = Attr.NewColour16(Colour16.White, Colour16.Blue);
		topBar     = Attr.NewColour16(Colour16.Black, Colour16.White);
	}

	private void AssertColour(string str) {
		auto colourStrings = GetColourStrings();
		
		if (str !in colourStrings) {
			throw new ThemeException(format("Invalid colour '%s'", str));
		}
	}

	static string Path(string name) {
		return format("%s/.config/noro/themes/%s.json", environment.get("HOME"), name);
	}

	void Load(JSONValue json) {
		Default();

		ubyte*[string] colours = [
			"windowFG":   &window.fg.byteColour,
			"windowBG":   &window.bg.byteColour,
			"dialogFG":   &dialog.fg.byteColour,
			"dialogBG":   &dialog.bg.byteColour,
			"background": &background.bg.byteColour,
			"topbarFG":   &topBar.fg.byteColour,
			"topbarBG":   &topBar.bg.byteColour
		];
		auto colourStrings = GetColourStrings();

		foreach (key, value ; colours) {
			if (key !in json) continue;

			AssertColour(json[key].str);
			*value = cast(ubyte) colourStrings[json[key].str];
		}
	}
}
