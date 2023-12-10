module noro.programs.input;

import std.array;
import std.algorithm;
import noro.types;
import noro.program;

class InputProgram : Program {
	string msg;
	string input;
	size_t caret;

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

	override void Input(KeyPress key) {
		if (key.mod > 0) return;

		switch (key.key) {
			case Key.Left: {
				if (caret > 0) {
					-- caret;
				}
				break;
			}
			case Key.Right: {
				if (caret < input.length) {
					++ caret;
				}
				break;
			}
			case Key.Backspace: {
				if (caret == 0) break;

				-- caret;
				input = cast(string) (cast(char[]) input).remove(caret);
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
			}
		}
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(Colour16.White);
		buf.SetFGColour(Colour16.Black);
		buf.Clear(' ');

		buf.caret = Vec2!ushort(0, 0);
		buf.Print(msg ~ '\n');

		auto inputLine = buf.caret.y;

		buf.SetBGColour(Colour16.Black);
		buf.SetFGColour(Colour16.White);
		buf.HLine(0, buf.caret.y, buf.GetSize().x, ' ');
		buf.Print(input);

		buf.caret = Vec2!ushort(cast(ushort) caret, inputLine);
	}
}
