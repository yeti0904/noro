module noro.programs.editor;

import std.array;
import std.algorithm;
import noro.types;
import noro.program;

class EditorProgram : Program {
	string[]    buffer;
	Vec2!size_t caret;

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
				case '\n': {
					if (caret.x < (cast(long) buffer[caret.y].length) - 1) {
						buffer.insertInPlace(caret.y + 1, buffer[caret.y][caret.x .. $]);

						auto line = cast(char[]) buffer[caret.y];
						/*if (caret.x > 0) { // ?
							buffer[caret.y] = cast(string) line.remove(caret.x);
						}*/
						buffer[caret.y] = buffer[caret.y][0 .. caret.x];
					}
					else {
						buffer.insertInPlace(caret.y + 1, "");
					}

					++ caret.y;
					caret.x = 0;
					break;
				}
				case Key.Up: {
					if (caret.y > 0) {
						-- caret.y;
						if (caret.x > buffer[caret.y].length) {
							caret.x = buffer[caret.y].length;
						}
					}
					else {
						caret.x = 0;
					}
					break;
				}
				case Key.Down: {
					if (caret.y < buffer.length - 1) {
						++ caret.y;
						if (caret.x > buffer[caret.y].length) {
							caret.x = buffer[caret.y].length;
						}
					}
					else {
						caret.x = buffer[caret.y].length;
					}
					break;
				}
				case Key.Left: {
					if (caret.x > 0) {
						-- caret.x;
					}
					else if (caret.y > 0) {
						-- caret.y;
						caret.x = buffer[caret.y].length;
					}
					break;
				}
				case Key.Right: {
					if (caret.x < buffer[caret.y].length) {
						++ caret.x;
					}
					else if (
						(caret.x >= buffer[caret.y].length) &&
						(caret.y != buffer.length - 1)
					) {
						++ caret.y;
						caret.x = 0;
					}
					break;
				}
				case Key.Backspace: {
					if (caret.x > 0) {
						-- caret.x;
						auto line = cast(char[]) buffer[caret.y];
						buffer[caret.y] = cast(string) line.remove(caret.x);
					}
					else if (caret.y > 0) {
						buffer[caret.y - 1] ~= buffer[caret.y];
						auto lineSize = buffer[caret.y].length;
						buffer = buffer.remove(caret.y);
						-- caret.y;
						caret.x = buffer[caret.y].length - lineSize;
					}
					break;
				}
				default: {
					import std.stdio : stderr, writeln;
					stderr.writeln(key);
				}
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

		buf.caret = Vec2!ushort(cast(ushort) caret.x, cast(ushort) caret.y);
	}
}
