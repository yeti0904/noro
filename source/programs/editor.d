module noro.programs.editor;

import std.uni;
import std.utf;
import std.file;
import std.path;
import std.array;
import std.format;
import std.algorithm;
import noro.app;
import noro.util;
import noro.theme;
import noro.types;
import noro.program;
import noro.ui.window;

class EditorProgram : Program {
	string[]    buffer;
	Vec2!size_t caret;
	ThemeColour colours;
	Vec2!size_t scroll;
	string      fileName;

	this() {
		buffer  = [""];
		colours = ThemeColour.Window;
	}

	override void Init() {
		parent.borderColour = colours;
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

	void CursorUp() {
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
	}

	void CursorDown() {
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
	}

	void CursorLeft() {
		if (caret.x > 0) {
			-- caret.x;
		}
		else if (caret.y > 0) {
			-- caret.y;
			caret.x = buffer[caret.y].length;
		}
	}

	void CursorRight() {
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
	}

	void CursorWordLeft() {
		CursorLeft();

		if (caret.x == buffer[caret.y].length) return;

		while (buffer[caret.y][caret.x].isWhite()) {
			if (caret.x == 0) return;
			CursorLeft();
		}

		CursorLeft();
		while (buffer[caret.y][caret.x].IsWordChar()) {
			if (caret.x == 0) return;
			if (buffer[caret.y][caret.x].IsWordChar()) CursorLeft();
		}

		CursorRight();
	}

	void CursorWordRight() {
		if (caret.x == buffer[caret.y].length) {
			CursorRight();
			return;
		}
		
		while (buffer[caret.y][caret.x].isWhite()) {
			CursorRight();

			if (caret.x >= buffer[caret.y].length) return;
		}

		do {
			if (caret.x > buffer[caret.y].length) {
				CursorRight();
				return;
			}

			CursorRight();
		} while(
			(caret.x != buffer[caret.y].length) &&
			buffer[caret.y][caret.x].IsWordChar()
		);
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
					CursorUp();
					break;
				}
				case Key.Down: {
					CursorDown();
					break;
				}
				case Key.Left: {
					CursorLeft();
					break;
				}
				case Key.Right: {
					CursorRight();
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
					if (!fileName.empty) {
						// TODO: do this less slowly
						std.file.write(fileName, buffer.join("\n"));
						return;
					}

					CreateInputWindow(
						cast(Program) this, "Save file", "Type a filename:",
						(Program program, string path) {
							auto app = App.Instance();
							
							try {
								std.file.write(path, buffer.join("\n"));
							}
							catch (FileException) {
								app.NewAlert("Failed to write file", 3);
								return;
							}

							app.NewAlert("Saved file", 3);

							auto editor     = cast(EditorProgram) program;
							editor.fileName = path;
							editor.parent.name = format("Editor (%s)", baseName(path));
						}
					);
					break;
				}
				case 'o': {
					CreateInputWindow(
						cast(Program) this, "Open file", "Type a filename",
						(Program program, string path) {
							auto app = App.Instance();
							
							try {
								buffer = readText(path).split("\n"); // TODO: faster
							}
							catch (FileException) {
								app.NewAlert("Failed to open file", 3);
								return;
							}
							catch (UTFException) {
								app.NewAlert("UTF decoding error", 3);
								return;
							}
							
							caret  = Vec2!size_t(0, 0);

							app.NewAlert("Opened file", 3);
						}
					);
					break;
				}
				case Key.Left:  CursorWordLeft(); break;
				case Key.Right: CursorWordRight(); break;
				default: break; // TODO: error
			}
		}
		else if (key.mod == KeyMod.Shift) {
			
		}
	}

	override void OnResize(Vec2!ushort size) {
		Scroll();
	}

	override void Render(Buffer buf) {
		buf.attr = App.GetTheme().GetColour(colours);
		
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
