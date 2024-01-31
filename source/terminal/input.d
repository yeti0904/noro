module noro.terminal.input;

import std.uni;
import std.conv;
import std.string;
import noro.binding;

enum Key {
	Null = 0,
	// regular keys
	Tab       = 9,
	Backspace = 127,
	// VT sequences
	Home = 1000000,
	Insert,
	Delete,
	End,
	PgUp,
	PgDn,
	Home2,
	End2,
	F0 = 1000010,
	F1,
	F2,
	F3,
	F4,
	F5,
	F6 = 1000017,
	F7,
	F8,
	F9,
	F10,
	F11 = 1000023,
	F12,
	F13,
	F14,
	F15 = 1000028,
	F16,
	F17 = 1000031,
	F18,
	F19,
	F20, 
	// XTerm keys
	Up,
	Down,
	Right,
	Left,
	Escape = '\x1b'
}

enum KeyMod {
	Shift = 0b00000001,
	Alt   = 0b00000010,
	Ctrl  = 0b00000100,
	Meta  = 0b00001000
}

struct KeyPress {
	dchar key;
	ubyte mod;

	this(dchar pkey) {
		key = pkey;
	}

	this(dchar pkey, ubyte pmod) {
		key = pkey;
		mod = pmod;
	}

	bool IsText() {
		if ((mod == 0) && (key == 9)) return true;
		
		return (mod == 0) && (key < 1000000) && (key >= 32) && (key != 127);
	}
}

static private bool inputBlocks;

void SetInputBlocks(bool on) {
	inputBlocks = on;
}

char GetChar() {
	termios oldInfo;
	termios info;
	tcgetattr(0, &info);
	tcgetattr(0, &oldInfo);
	
	info.c_lflag     &= ~ICANON;
	info.c_cc[VMIN]   = inputBlocks? 1 : 0;
	info.c_cc[VTIME]  = 0;
	tcsetattr(0, TCSANOW, &info); 
	
	char input = 0;
	if (read(0, &input, 1) == 0) {
		return Key.Null;
	}

	tcsetattr(0, TCSANOW, &oldInfo);
	return input;
}

static dchar VtKey(int num) {
	if ((num > 1) && (num < 35)) {
		return cast(dchar) num;
	}
	else {
		return 0;
	}
}

static dchar XTermKey(char ch) {
	switch (ch) {
		case 'A': return Key.Up;
		case 'B': return Key.Down;
		case 'C': return Key.Right;
		case 'D': return Key.Left;
		case 'F': return Key.End;
		case 'H': return Key.Home;
		default:  return Key.Null;
	}
}

ubyte GetMod(int mod) {
	-- mod;

	switch (mod) {
		case 1:  return KeyMod.Shift;
		case 2:  return KeyMod.Alt;
		case 3:  return KeyMod.Shift | KeyMod.Alt;
		case 4:  return KeyMod.Ctrl;
		case 5:  return KeyMod.Ctrl | KeyMod.Shift;
		case 6:  return KeyMod.Ctrl | KeyMod.Alt;
		case 7:  return KeyMod.Ctrl | KeyMod.Alt | KeyMod.Shift;
		default: return 0;
	}
}

KeyPress GetKey() {
	auto ch = GetChar();

	char NextChar() {
		ch = GetChar();
		return ch;
	}

	switch (ch) {
		case Key.Null:     return KeyPress(Key.Null, 0);
		case '\x1b':       break;
		case '\r':         return KeyPress('\n',    0);
		case 9:            return KeyPress(Key.Tab, 0);
		case ('a' & 0x1F): return KeyPress('a',    KeyMod.Ctrl);
		case ('b' & 0x1F): return KeyPress('b',    KeyMod.Ctrl);
		case ('c' & 0x1F): return KeyPress('c',    KeyMod.Ctrl);
		case ('d' & 0x1F): return KeyPress('d',    KeyMod.Ctrl);
		case ('e' & 0x1F): return KeyPress('e',    KeyMod.Ctrl);
		case ('f' & 0x1F): return KeyPress('f',    KeyMod.Ctrl);
		case ('g' & 0x1F): return KeyPress('g',    KeyMod.Ctrl);
		case ('h' & 0x1F): return KeyPress('h',    KeyMod.Ctrl);
		// case ('i' & 0x1F): return KeyPress('i',    KeyMod.Ctrl);
		case ('j' & 0x1F): return KeyPress('j',    KeyMod.Ctrl);
		case ('k' & 0x1F): return KeyPress('k',    KeyMod.Ctrl);
		case ('l' & 0x1F): return KeyPress('l',    KeyMod.Ctrl);
		// case ('m' & 0x1F): return KeyPress('m',  KeyMod.Ctrl);
		case ('n' & 0x1F): return KeyPress('n',    KeyMod.Ctrl);
		case ('o' & 0x1F): return KeyPress('o',    KeyMod.Ctrl);
		case ('p' & 0x1F): return KeyPress('p',    KeyMod.Ctrl);
		case ('q' & 0x1F): return KeyPress('q',    KeyMod.Ctrl);
		case ('r' & 0x1F): return KeyPress('r',    KeyMod.Ctrl);
		case ('s' & 0x1F): return KeyPress('s',    KeyMod.Ctrl);
		case ('t' & 0x1F): return KeyPress('t',    KeyMod.Ctrl);
		case ('u' & 0x1F): return KeyPress('u',    KeyMod.Ctrl);
		case ('v' & 0x1F): return KeyPress('v',    KeyMod.Ctrl);
		case ('w' & 0x1F): return KeyPress('w',    KeyMod.Ctrl);
		case ('x' & 0x1F): return KeyPress('x',    KeyMod.Ctrl);
		case ('y' & 0x1F): return KeyPress('y',    KeyMod.Ctrl);
		case ('z' & 0x1F): return KeyPress('z',    KeyMod.Ctrl);
		default:           return KeyPress(ch);
	}

	auto oldBlocks = inputBlocks;
	SetInputBlocks(true);

	NextChar();
	switch (ch) {
		case '\x1b': return KeyPress(Key.Escape);
		case '[': {
			NextChar();

			if (isNumeric("" ~ ch)) { // vt sequence
				int[]  numbers;
				string reading = "" ~ ch;

				while (true) {
					NextChar();

					if (ch == '~') {
						numbers ~= parse!int(reading);
						reading  = "";
						break;
					}
					else if (ch == ';') {
						numbers ~= parse!int(reading);
						reading  = "";
					}
					else if (isAlpha(ch)) {
						numbers ~= parse!int(reading);
						SetInputBlocks(oldBlocks);
						return KeyPress(XTermKey(ch), GetMod(numbers[$ - 1]));
					}
					else {
						reading ~= ch;
					}
				}

				SetInputBlocks(oldBlocks);
				if (numbers.length == 1) {
					return KeyPress(VtKey(numbers[0] + 1000000));
				}
				else if (numbers.length == 2) {
					return KeyPress(VtKey(numbers[0] + 1000000), GetMod(numbers[1]));
				}
				else {
					return KeyPress(Key.Null);
				}
			}
			else if (isAlpha(ch)) { // xterm sequence
				SetInputBlocks(oldBlocks);
				return KeyPress(XTermKey(ch));
			}
			else {
				SetInputBlocks(oldBlocks);
				return KeyPress(Key.Null);
			}
		}
		default: {
			SetInputBlocks(oldBlocks);
			return KeyPress(Key.Null);
		}
	}
}
