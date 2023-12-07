module noro.terminal.screen;

import std.stdio;
import noro.types;
import noro.binding;
import noro.terminal.terminal;

public import noro.terminal.buffer;

class Screen {
	Buffer  old;
	Buffer  buffer;
	termios originalTermios;

	this() {
		tcgetattr(0, &originalTermios);
	
		Terminal.SetAltBuffer(true);
		Terminal.SetEcho(false);
		buffer = new Buffer(Terminal.GetSize());
	}

	~this() {
		// Terminal.SetAltBuffer(false);
		// Terminal.SetEcho(true);
		tcsetattr(0, TCSAFLUSH, &originalTermios);
	}

	void Render() {
		size_t cellIndex;
		bool   check = true;

		if ((old is null) || (old.GetSize() != buffer.GetSize())) {
			check = false;
		}
		
		for (ushort y = 0; y < buffer.GetSize().y; ++ y) {
			for (ushort x = 0; x < buffer.GetSize().x; ++ x, ++ cellIndex) {
				auto cell = buffer.cells[cellIndex];
				Terminal.MoveCursor(Vec2!ushort(x, y));

				if (check) {
					auto oldCell = old.cells[cellIndex];
					if (oldCell == cell) {
						continue;
					}
				}

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
				
				write(cell.ch);
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
