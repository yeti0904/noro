module noro.programs.editor;

import std.uni;
import std.utf;
import std.file;
import std.path;
import std.array;
import std.format;
import std.typecons;
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
	Vec2!size_t selectionPos;
	bool        selected;
	string      clipboard;

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

	Vec2!size_t SelectionStart() {
		if (caret.y > selectionPos.y) {
			return selectionPos;
		}
		else if (caret.y == selectionPos.y) {
			if (caret.x > selectionPos.x) {
				return selectionPos;
			}
			else {
				return caret;
			}
		}
		else {
			return caret;
		}
	}

	Vec2!size_t SelectionEnd() {
		return SelectionStart() == caret?
			selectionPos : Vec2!size_t(caret.x, caret.y);
	}

	void DeleteSelection() {
		if (selected) {
			auto selStart = SelectionStart();
			auto selEnd   = SelectionEnd(); // selEnd more like bellEnd

			if (selStart.y == selEnd.y) {
				auto part1 = buffer[caret.y][0 .. selStart.x];
				auto part2 = buffer[caret.y][selEnd.x + 1 .. $];

				buffer[caret.y] = part1 ~ part2;
				caret.x         = part1.length;
			}
			else {
				buffer   = buffer.remove(tuple(selStart.y + 1, selEnd.y));
				selEnd.y = selStart.y + 1;

				auto part1 = buffer[selStart.y][0 .. selStart.x];
				auto part2 = buffer[selEnd.y][selEnd.x .. $];

				buffer = buffer.remove(selEnd.y);

				caret.y         = selStart.y;
				caret.x         = part1.length;
				buffer[caret.y] = part1 ~ part2;
			}

			selected = false;
		}
	}

	string[] SelectionContents() {
		string[] contents;
		auto     selStart = SelectionStart();
		auto     selEnd   = SelectionEnd();

		if (selStart.y == selEnd.y) {
			contents ~= buffer[selStart.y][
				selStart.x .. selStart.x + (selEnd.x - selStart.x)
			];
		}
		else {
			contents ~= buffer[selStart.y][selStart.x .. $];

			for (size_t i = selStart.y; i < selEnd.y; ++ i) {
				contents ~= buffer[i];
			}

			contents ~= buffer[selEnd.y][0 .. selEnd.x];
		}

		return contents;
	}

	void InsertChar(dchar ch) {
		switch (ch) {
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
			default: {
				buffer[caret.y].insertInPlace(caret.x, ch);
				++ caret.x;
			}
		}
	}

	void InsertString(string str) {
		foreach (dchar ch ; str) {
			InsertChar(ch);
		}
	}

	void OpenFile(string path) {
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
		
		caret = Vec2!size_t(0, 0);

		app.NewAlert("Opened file", 3);
		fileName    = path;
		parent.name = format("Editor (%s)", baseName(path));
	}

	override void Input(KeyPress key) {
		if (key.IsText()) {
			InsertChar(key.key);
			return;
		}

		if (key.mod == 0) {
			switch (key.key) {
				case '\n': {
					InsertChar('\n');
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
					if (selected) {
						DeleteSelection();
						break;
					}
					
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
			
			selected = false;
		}
		else if (key.mod == KeyMod.Shift) {
			switch (key.key) {
				case Key.Left: {
					if (!selected) {
						selected     = true;
						selectionPos = caret;
					}

					CursorLeft();
					break;
				}
				case Key.Right: {
					if (!selected) {
						selected     = true;
						selectionPos = caret;
					}

					CursorRight();
					break;
				}
				case Key.Up: {
					if (!selected) {
						selected     = true;
						selectionPos = caret;
					}

					CursorUp();
					break;
				}
				case Key.Down: {
					if (!selected) {
						selected     = true;
						selectionPos = caret;
					}

					CursorDown();
					break;
				}
				default: break;
			}
		}
		else if (key.mod == (KeyMod.Ctrl | KeyMod.Shift)) {
			switch (key.key) {
				case Key.Left: {
					if (!selected) {
						selected     = true;
						selectionPos = caret;
					}

					CursorWordLeft();
					break;
				}
				case Key.Right: {
					if (!selected) {
						selected     = true;
						selectionPos = caret;
					}

					CursorWordRight();
					break;
				}
				default: break;
			}
		}
		else if (key.mod == KeyMod.Ctrl) {
			selected = false;
			
			switch (key.key) {
				case 'c': {
					clipboard = SelectionContents().join("\n");
					break;
				}
				case 'v': {
					InsertString(clipboard);
					break;
				}
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

							auto editor        = cast(EditorProgram) program;
							editor.fileName    = path;
							editor.parent.name = format("Editor (%s)", baseName(path));
						}
					);
					break;
				}
				case 'o': {
					CreateInputWindow(
						cast(Program) this, "Open file", "Type a filename",
						(Program program, string path) {
							auto editor = cast(EditorProgram) program;
							editor.OpenFile(path);
						}
					);
					break;
				}
				case Key.Left:  CursorWordLeft(); break;
				case Key.Right: CursorWordRight(); break;
				default: break; // TODO: error
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

		auto selStart = SelectionStart();
		auto selEnd   = SelectionEnd();

		bool inSelection;

		void InSelection(size_t x, size_t y) {
			if (
				selected && !inSelection && (x == selStart.x) && (y == selStart.y)
			) {
				inSelection = true;
				swap(buf.attr.fg, buf.attr.bg);
			}

			if (
				inSelection && (x == selEnd.x) && (y == selEnd.y)
			) {
				inSelection = false;
				swap(buf.attr.fg, buf.attr.bg);
			}
		}

		foreach (y, ref line ; buffer[scroll.y .. $]) {
			InSelection(0, y);
			
			foreach (x, dchar ch ; line) {
				// buf.Print(cast(ushort) x, cast(ushort) y, ch);

				InSelection(x, y);
				buf.Print(ch);
			}
			buf.Print(" \n");
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
