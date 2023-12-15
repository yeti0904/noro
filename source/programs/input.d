module noro.programs.input;

import std.array;
import std.algorithm;
import noro.types;
import noro.program;

class InputProgram : Program {
	string msg;
	string input;
	size_t caret;
	size_t scroll;

	void delegate(string) onComplete;

	this(string pmsg) {
		msg = pmsg;
	}

	this(string pmsg, void delegate(string) pfunc) {
		msg        = pmsg;
		onComplete = pfunc;
	}

	override void Init() {
		parent.borderBG = Colour16.White;
		parent.borderFG = Colour16.Black;
	}

	override void Update() {
		
	}

	void ScrollRight() {
		auto bufSize = parent.contents.GetSize();

		if (caret - scroll >= bufSize.x) ++ scroll;
	}

	void ScrollLeft() {
		long scaret  = cast(long) caret;
		long sscroll = cast(long) scroll;

		if (scaret - sscroll < 0) -- scroll;
	}

	override void Input(KeyPress key) {
		if (key.mod > 0) return;

		switch (key.key) {
			case Key.Left: {
				if (caret > 0) {
					-- caret;
					ScrollLeft();
				}
				break;
			}
			case Key.Right: {
				if (caret < input.length) {
					++ caret;
					ScrollRight();
				}
				break;
			}
			case Key.Backspace: {
				if (caret == 0) break;

				-- caret;
				input = cast(string) (cast(char[]) input).remove(caret);
				ScrollLeft();
				break;
			}
			case '\n': {
				onComplete(input);
				break;
			}
			default: {
				if (!key.IsText()) break;
				
				input.insertInPlace(caret, key.key);
				++ caret;
				ScrollRight();
			}
		}
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(Colour16.White);
		buf.SetFGColour(Colour16.Black);
		buf.Clear(' ');

		buf.caret = Vec2!ushort(0, 0);
		buf.Print(msg ~ '\n');
		++ buf.caret.y;

		auto inputLine = buf.caret.y;

		buf.SetBGColour(Colour16.Black);
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
