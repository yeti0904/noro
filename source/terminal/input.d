module noro.terminal.input;

import std.uni;
import std.conv;
import std.string;
import noro.binding;

enum Key {
	Null = 0,
	// VT sequences
	Home = 1000,
	Insert,
	Delete,
	End,
	PgUp,
	PgDn,
	Home2,
	End2,
	F0 = 1010,
	F1,
	F2,
	F3,
	F4,
	F5,
	F6 = 1017,
	F7,
	F8,
	F9,
	F10,
	F11 = 1023,
	F12,
	F13,
	F14,
	F15 = 1028,
	F16,
	F17 = 1031,
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

struct KeyPress {
	dchar key;
	bool  ctrl;

	this(dchar pkey) {
		key = pkey;
	}

	this(dchar pkey, bool pctrl) {
		key  = pkey;
		ctrl = pctrl;
	}
}

char GetChar() {
	termios oldInfo;
	termios info;
	tcgetattr(0, &info);
	tcgetattr(0, &oldInfo);
	
	info.c_lflag     &= ~ICANON;
	info.c_cc[VMIN]   = 1;
	info.c_cc[VTIME]  = 0;
	tcsetattr(0, TCSANOW, &info); 
	
	char input;
	read(0, &input, 1);

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
		default:  return Key.Null;
	}
}

KeyPress GetKey() {
	auto ch = GetChar();

	char NextChar() {
		ch = GetChar();
		return ch;
	}

	switch (ch) {
		case '\x1b':       break;
		case ('a' & 0x1F): return KeyPress('a', true);
		case ('b' & 0x1F): return KeyPress('b', true);
		case ('c' & 0x1F): return KeyPress('c', true);
		case ('d' & 0x1F): return KeyPress('d', true);
		case ('e' & 0x1F): return KeyPress('e', true);
		case ('f' & 0x1F): return KeyPress('f', true);
		case ('g' & 0x1F): return KeyPress('g', true);
		case ('h' & 0x1F): return KeyPress('h', true);
		case ('i' & 0x1F): return KeyPress('i', true);
		case ('j' & 0x1F): return KeyPress('j', true);
		case ('k' & 0x1F): return KeyPress('k', true);
		case ('l' & 0x1F): return KeyPress('l', true);
		case ('m' & 0x1F): return KeyPress('m', true);
		case ('n' & 0x1F): return KeyPress('n', true);
		case ('o' & 0x1F): return KeyPress('o', true);
		case ('p' & 0x1F): return KeyPress('p', true);
		case ('q' & 0x1F): return KeyPress('q', true);
		case ('r' & 0x1F): return KeyPress('r', true);
		case ('s' & 0x1F): return KeyPress('s', true);
		case ('t' & 0x1F): return KeyPress('t', true);
		case ('u' & 0x1F): return KeyPress('u', true);
		case ('v' & 0x1F): return KeyPress('v', true);
		case ('w' & 0x1F): return KeyPress('w', true);
		case ('x' & 0x1F): return KeyPress('x', true);
		case ('y' & 0x1F): return KeyPress('y', true);
		case ('z' & 0x1F): return KeyPress('z', true);
		default:           return KeyPress(ch);
	}

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
						auto ret = KeyPress(XTermKey(ch));

						if (numbers[1] == 4) {
							ret.ctrl = true;
						}
						return ret;
					}
					else {
						reading ~= ch;
					}
				}

				if (numbers.length == 1) {
					return KeyPress(VtKey(numbers[0] + 1000));
				}
				else if (numbers.length == 2) {
					auto ret = KeyPress(VtKey(numbers[0] + 1000));
					
					numbers[1] -= 1;

					if (numbers[1] == 4) {
						ret.ctrl = true;
					}
					return ret;
				}
				else {
					return KeyPress(Key.Null);
				}
			}
			else if (isAlpha(ch)) { // xterm sequence
				return KeyPress(XTermKey(ch));
			}
			else {
				return KeyPress(Key.Null);
			}
		}
		default: return KeyPress(Key.Null);
	}
}
