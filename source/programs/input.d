module noro.programs.input;

import std.array;
import std.algorithm;
import noro.app;
import noro.types;
import noro.theme;
import noro.program;

class InputProgram : Program {
	string      msg;
	string      input;
	size_t      caret;
	size_t      scroll;
	Program     program;
	ThemeColour colours;

	void delegate(Program, string) onComplete;

	this(string pmsg) {
		msg           = pmsg;
		cursorVisible = true;
	}

	this(string pmsg, void delegate(Program, string) pfunc, Program pprogram) {
		msg           = pmsg;
		onComplete    = pfunc;
		program       = pprogram;
		colours       = ThemeColour.Dialog;
		cursorVisible = true;
	}

	override void Init() {
		parent.borderColour = colours;
	}

	override void Update() {
		
	}

	void Scroll() {
		auto bufSize = parent.contents.GetSize();

		while (caret - scroll >= bufSize.x) ++ scroll;
		if    (caret < scroll)              scroll = caret;
	}

	override void Input(KeyPress key) {
		if (key.mod > 0) return;

		switch (key.key) {
			case Key.Left: {
				if (caret > 0) {
					-- caret;
					Scroll();
				}
				break;
			}
			case Key.Right: {
				if (caret < input.length) {
					++ caret;
					Scroll();
				}
				break;
			}
			case Key.Backspace: {
				if (caret == 0) break;

				-- caret;
				input = cast(string) (cast(char[]) input).remove(caret);
				Scroll();
				break;
			}
			case '\n': {
				onComplete(program, input);
				App.Instance().GetUI().DeleteTop(); // TODO: make this safer (can cause bugs)
				break;
			}
			default: {
				if (!key.IsText()) break;
				
				input.insertInPlace(caret, key.key);
				++ caret;
				Scroll();
			}
		}
	}

	override void OnResize(Vec2!ushort size) {
		Scroll();
	}

	override void Render(Buffer buf) {
		buf.attr = App.GetTheme().GetColour(colours);
		buf.Clear(' ');

		buf.caret = Vec2!ushort(0, 0);
		buf.Print(msg ~ '\n');
		++ buf.caret.y;

		auto inputLine = buf.caret.y;

		buf.SetBGColour(Colour16.Black); // TODO: make this customisable
		buf.SetFGColour(Colour16.White);
		buf.HLine(0, buf.caret.y, buf.GetSize().x, ' ');

		buf.caret = Vec2!ushort(0, inputLine);
		for (size_t i = scroll; i < input.length; ++ i) {
			if (i - scroll >= buf.GetSize().x) break;
			buf.Print(input[i]);
		}

		buf.caret = Vec2!ushort(cast(ushort) (caret - scroll), inputLine);
	}
}
