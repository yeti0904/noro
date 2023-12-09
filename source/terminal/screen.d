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
		termios term;
		tcgetattr(0, &term);
		tcgetattr(0, &originalTermios);
	
		Terminal.SetAltBuffer(true);
		// Terminal.SetEcho(false);
		term.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
		term.c_oflag &= ~(OPOST);
		term.c_cflag |= (CS8);
		term.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
		tcsetattr(0, TCSAFLUSH, &term);
  
		buffer = new Buffer(Terminal.GetSize());
	}

	~this() {
		Terminal.SetAltBuffer(false);
		// Terminal.SetEcho(true);
		tcsetattr(0, TCSAFLUSH, &originalTermios);
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
