module noro.terminal.screen;

import std.stdio;
import noro.types;
import noro.binding;
import noro.terminal.input;
import noro.terminal.terminal;

public import noro.terminal.buffer;

class Screen {
	Buffer  old;
	Buffer  buffer;
	termios originalTermios;

	this() {
		Terminal.Init();
		Terminal.SetAltBuffer(true);
		Terminal.SetRawMode(true);
		// Terminal.SetEcho(false);

		SetInputBlocks(true);
  
		buffer = new Buffer(Terminal.GetSize());
	}

	~this() {
		Terminal.SetAltBuffer(false);
		Terminal.SetRawMode(false);
		// Terminal.SetEcho(true);
	}

	void Render() {
		size_t cellIndex;
		bool   check = true;
		Attr   lastAttr;

		if ((old is null) || (old.GetSize() != buffer.GetSize())) {
			check = false;
		}
		
		for (ushort y = 0; y < buffer.GetSize().y; ++ y) {
			for (ushort x = 0; x < buffer.GetSize().x; ++ x, ++ cellIndex) {
				auto cell = buffer.cells[cellIndex];

				if (check) {
					auto oldCell = old.cells[cellIndex];
					if (oldCell == cell) {
						continue;
					}
				}
				
				Terminal.MoveCursor(Vec2!ushort(x, y));

				if ((cellIndex == 0) || (cell.attr != lastAttr)) {
					switch (cell.attr.mode) {
						case ColourMode.Colour16: {
							writef(
								"\x1b[%d;%dm", cell.attr.fg.byteColour,
								cell.attr.bg.byteColour + 10
							);
							break;
						}
						default: assert(0);
					}
				}
				
				write(cell.ch);
				lastAttr = cell.attr;
			}
		}

		Terminal.MoveCursor(buffer.caret);
		stdout.flush();
		old = buffer;
		buffer = new Buffer(Terminal.GetSize());

		if (old.GetSize() == buffer.GetSize()) {
			buffer.FromBuffer(old);
		}
	}
}
