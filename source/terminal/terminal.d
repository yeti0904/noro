module noro.terminal.terminal;

import std.stdio;
import std.string;
import noro.util;
import noro.types;
import noro.binding;

static termios originalTermios;

class TerminalException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

class Terminal {
	static void Init() {
		tcgetattr(0, &originalTermios);
	}

	static Vec2!ushort GetSize() {
		extern(C) int open(const char*, int, ...);
		
		version (linux) {
			winsize winSize;
			stdout.flush();
			
			if (ioctl(1, TIOCGWINSZ, &winSize) == -1) {
				throw new TerminalException(cast(string) strerror(errno).fromStringz());
			}
			
			return Vec2!ushort(winSize.ws_col, winSize.ws_row);
		}
		else {
			winsize winSize;

			int fd = File("/dev/tty", "rwb").fileno;

			if (ioctl(fd, TIOCGWINSZ, &winSize) == -1) {
				throw new TerminalException(cast(string) strerror(errno).fromStringz());
			}

			return Vec2!ushort(winSize.ws_col, winSize.ws_row);
		}
	}

	static void Clear() {
		writef("\x1b[J");
		stdout.flush();
	}

	static void MoveCursor(Vec2!ushort pos) {
		writef("\x1b[%d;%dH", pos.y + 1, pos.x + 1);
	}

	static void SetColour16(ubyte colour) {
		writef("\x1b[%dm", colour);
	}

	static void SetFGColour256(ubyte colour) {
		writef("\x1b[38;5;%dm", colour);
	}

	static void SetBGColour256(ubyte colour) {
		writef("\x1b[48;5;%dm", colour);
	}

	static void SetFGColourRGB(ubyte r, ubyte g, ubyte b) {
		writef("\x1b[38;2;%d;%d;%dm", r, g, b);
	}

	static void SetBGColourRGB(ubyte r, ubyte g, ubyte b) {
		writef("\x1b[48;2;%d;%d;%dm", r, g, b);
	}

	static void SetAltBuffer(bool on) {
		writef("\x1b[?1049%c", on? 'h' : 'l');
		stdout.flush();
	}

	static void SetEcho(bool on) {
		termios term;
		tcgetattr(0, &term);

		if (on) {
			term.c_lflag |= ECHO;
		}
		else {
			term.c_lflag &= ~ECHO;
		}
		
		tcsetattr(0, 0, &term);
	}

	static void SetCursorVisibility(bool on) {
		writef("\x1b[?25%c", on? 'h' : 'l');
	}

	static void SetTerminalTitle(string title) {
		writef("\x1b]0;%s\007", title);
		stdout.flush();
	}

	static void SetRawMode(bool on) {
		if (on) {
			termios term;
			tcgetattr(0, &term);
			term.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
			term.c_oflag &= ~(OPOST);
			term.c_cflag |= (CS8);
			term.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
			tcsetattr(0, TCSAFLUSH, &term);
		}
		else {
			tcsetattr(0, TCSAFLUSH, &originalTermios);
		}
	}
}
