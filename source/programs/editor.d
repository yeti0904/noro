module noro.programs.editor;

import std.array;
import std.algorithm;
import noro.types;
import noro.program;

class EditorProgram : Program {
	string[]    buffer;
	Vec2!ushort caret;

	this() {
		buffer = [""];
	}

	override void Update() {
		
	}

	override void Input(KeyPress key) {
		if (key.IsText()) {
			buffer[caret.y].insertInPlace(caret.x, key.key);
			++ caret.x;
			return;
		}

		if (key.mod == 0) {
			switch (key.key) {
				case Key.Left: {
					if (caret.x > 0) -- caret.x;
					break;
				}
				case Key.Right: {
					if (caret.x < buffer[caret.y].length - 1) ++ caret.x;
					break;
				}
				case Key.Backspace: {
					-- caret.x;
					auto line = cast(char[]) buffer[caret.y];
					buffer[caret.y] = cast(string) line.remove(caret.x);
					break;
				}
				default: break;
			}
		}
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(Colour16.Black);
		buf.SetFGColour(Colour16.White);
		
		buf.Clear(' ');
		buf.caret = Vec2!ushort(0, 0);

		foreach (y, ref line ; buffer) {
			foreach (x, dchar ch ; line) {
				buf.Print(cast(ushort) x, cast(ushort) y, ch);
			}
		}

		buf.caret = caret;
	}
}
