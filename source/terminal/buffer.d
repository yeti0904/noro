module noro.terminal.buffer;

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
}

enum Character {
	CornerUL = '┌',
	CornerLL = '└',
	CornerUR = '┐',
	CornerLR = '┘',
	VLine    = '│',
	HLine    = '─'
}

struct Cell {
	dchar ch = ' ';
	Attr  attr;

	this(dchar pch) {
		ch                 = pch;
		attr.fg.byteColour = Colour16.Default;
		attr.bg.byteColour = Colour16.Default;
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
		attr.fg.byteColour = Colour16.Default;
		attr.bg.byteColour = Colour16.Default;
	}

	void Resize(ushort w, ushort h) {
		size  = Vec2!ushort(w, h);
		cells = new Cell[](w * h);
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

	void Print(dchar ch) {
		cells[GetCaretIndex()] = Cell(ch, attr);
		
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
}
