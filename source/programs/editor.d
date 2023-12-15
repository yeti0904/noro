module noro.programs.editor;

import std.file;
import std.array;
import std.algorithm;
import noro.app;
import noro.util;
import noro.types;
import noro.program;
import noro.ui.window;

class EditorProgram : Program {
	string[]    buffer;
	Vec2!size_t caret;
	Colour16    bg;
	Colour16    fg;
	Vec2!size_t scroll;

	this() {
		buffer = [""];
		bg     = Colour16.Black;
		fg     = Colour16.White;
	}

	override void Init() {
		parent.borderBG = bg;
		parent.borderFG = fg;
	}

	override void Update() {
		
	}

	void Scroll() {
		auto bufSize = parent.contents.GetSize();

		while (caret.y - scroll.y >= bufSize.y) {
			++ scroll.y;
		}

		if (caret.y < scroll.y) {
			scroll.y = caret.y;
		}
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
					Scroll();
					break;
				}
				case Key.Up: {
					if (caret.y > 0) {
						-- caret.y;
						if (caret.x > buffer[caret.y].length) {
							caret.x = buffer[caret.y].length;
						}
						Scroll();
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
						Scroll();
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
						Scroll();
						caret.x = buffer[caret.y].length - lineSize;
					}
					break;
				}
				default: break;
			}
		}
		else if (key.mod == KeyMod.Ctrl) {
			switch (key.key) {
				case 's': {
					CreateInputWindow("Save file", "Type a filename:", (string path) {
						std.file.write(path, buffer.join("\n")); // TODO: error
						
						App.Instance().ui.DeleteTop();
					});
					break;
				}
				case 'o': {
					CreateInputWindow("Open file", "Type a filename", (string path) {
						buffer = readText(path).split("\n"); // TODO: error
						caret  = Vec2!size_t(0, 0);

						App.Instance().ui.DeleteTop();
					});
					break;
				}
				default: break; // TODO: error
			}
		}
	}

	override void OnResize(Vec2!ushort size) {
		Scroll();
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(bg);
		buf.SetFGColour(fg);
		
		buf.Clear(' ');
		buf.caret = Vec2!ushort(0, 0);

		foreach (y, ref line ; buffer[scroll.y .. $]) {
			foreach (x, dchar ch ; line) {
				// buf.Print(cast(ushort) x, cast(ushort) y, ch);
				buf.Print(ch);
			}
			buf.Print('\n');
		}

		ushort caretX;

		foreach (i, ref ch ; buffer[caret.y]) {
			if (i >= caret.x) break;
			
			switch (ch) {
				case '\t': {
					caretX += 4;
					break;
				}
				default: ++ caretX;
			}
		}

		buf.caret = Vec2!ushort(caretX, cast(ushort) (caret.y - scroll.y));
	}
}
