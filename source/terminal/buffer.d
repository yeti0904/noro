module noro.terminal.buffer;

import std.format;
import noro.types;

enum ColourMode {
	Colour16,
	Colour256,
	TrueColour
}

enum Colour16 {
	Black = 30,
	Red,
	Green,
	Yellow,
	Blue,
	Magenta,
	Cyan,
	White,
	Default     = 39,
	BrightBlack = 90,
	BrightRed,
	BrightGreen,
	BrightYellow,
	BrightBlue,
	BrightMagenta,
	BrightCyan,
	BrightWhite
}

union Colour {
	ubyte   byteColour;
	TColour tColour;
}

struct TColour {
	ubyte r, g, b;
}

struct Attr {
	ColourMode mode = ColourMode.Colour16;
	Colour     fg;
	Colour     bg;

	bool opEquals(Attr b) {
		if (mode != b.mode) return false;

		switch (mode) {
			case ColourMode.Colour16: {
				return (
					(fg.byteColour == b.fg.byteColour) &&
					(bg.byteColour == b.bg.byteColour)
				);
			}
			default: assert(0);
		}
	}
}

enum Character {
	CornerUL = '┌',
	CornerLL = '└',
	CornerUR = '┐',
	CornerLR = '┘',
	VLine    = '│',
	HLine    = '─',
	DCornerUL = '╔',
	DCornerLL = '╚',
	DCornerUR = '╗',
	DCornerLR = '╝',
	DVLine    = '║',
	DHLine    = '═'
}

struct Cell {
	dchar ch = ' ';
	Attr  attr;

	this(dchar pch) {
		ch                 = pch;
		attr.fg.byteColour = Colour16.White;
		attr.bg.byteColour = Colour16.Black;
	}

	this(dchar pch, Attr pattr) {
		ch   = pch;
		attr = pattr;
	}
}

class BufferException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

class Buffer {
	Cell[]      cells;
	Vec2!ushort caret;
	Attr        attr;

	private Vec2!ushort size;

	this(Vec2!ushort size) {
		Resize(size.x, size.y);
		attr.fg.byteColour = Colour16.White;
		attr.bg.byteColour = Colour16.Black;

		foreach (ref cell ; cells) {
			cell.attr = attr;
		}
	}

	void Resize(ushort w, ushort h) {
		if (cells is null) {
			cells = new Cell[](w * h);
			size  = Vec2!ushort(w, h);
			return;
		}

		auto newCells = new Cell[](w * h);

		for (ushort x = 0; x < w; ++ x) {
			for (ushort y = 0; y < h; ++ y) {
				if ((x >= w) || (y >= h)) {
					continue;
				}
				else if ((x >= size.x) || (y >= size.y)) {
					newCells[(y * w) + x] = Cell(' ');
				}
				else {
					newCells[(y * w) + x] = cells[GetIndex(x, y)];
				}
			}
		}

		cells = newCells;
		size  = Vec2!ushort(w, h);
	}

	Vec2!ushort GetSize() {
		return size;
	}

	size_t GetIndex(ushort x, ushort y) {
		return (y * size.x) + x;
	}

	size_t GetCaretIndex() {
		return GetIndex(caret.x, caret.y);
	}

	void Print(ushort x, ushort y, dchar ch) {
		if ((x >= size.x) || (y >= size.y)) {
			return;
		}

		cells[GetIndex(x, y)] = Cell(ch, attr);
	}

	void Print(dchar ch) {
		if ((caret.x < size.x) && (caret.y < size.y)) {
			cells[GetCaretIndex()] = Cell(ch, attr);
		}
		
		++ caret.x;
		if (caret.x >= size.x) {
			++ caret.y;
			caret.x = 0;
		}
	}

	void Print(string str) {
		foreach (dchar ch ; str) {
			Print(ch);
		}
	}
	
	void Printf(Char, A...)(in Char[] fmt, A args) {
		Print(format(fmt, args));
	}

	void SetFGColour(Colour16 colour) {
		attr.mode          = ColourMode.Colour16;
		attr.fg.byteColour = cast(ubyte) colour;
	}

	void SetBGColour(Colour16 colour) {
		attr.mode          = ColourMode.Colour16;
		attr.bg.byteColour = cast(ubyte) colour;
	}

	void Clear(dchar ch) {
		foreach (ref cell ; cells) {
			cell = Cell(ch, attr);
		}
	}

	void FromBuffer(Buffer other) {
		cells = other.cells.dup;
		caret = other.caret;
		attr  = other.attr;
		size  = other.GetSize();
	}

	void BlitBuffer(Buffer other, ushort x, ushort y) {
		for (ushort iy = 0; iy < other.GetSize().y; ++ iy) {
			for (ushort ix = 0; ix < other.GetSize().x; ++ ix) {
				auto pos = Vec2!ushort(cast(ushort) (x + ix), cast(ushort) (y + iy));
				if ((pos.x >= size.x) || (pos.y >= size.y)) continue;
				
				cells[GetIndex(pos.x, pos.y)] = other.cells[other.GetIndex(ix, iy)];
			}
		}
	}

	void HLine(ushort x, ushort y, ushort len, dchar ch) {
		foreach (i ; 0 .. len) {
			Print(cast(ushort) (x + i), y, ch);
		}
	}

	void VLine(ushort x, ushort y, ushort len, dchar ch) {
		foreach (i ; 0 .. len) {
			Print(x, cast(ushort) (y + i), ch);
		}
	}
}
