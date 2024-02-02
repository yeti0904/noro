module noro.binding;

/************************/
/*       ioctl          */
/************************/

extern(C) int ioctl(int fildes, int request, ...);

struct winsize {
	ushort ws_row;
	ushort ws_col;
	ushort ws_xpixel;
	ushort ws_ypixel;
}

const int TIOCGWINSZ = 21523;

/************************/
/*       termios        */
/************************/
alias cc_t     = ubyte;
alias speed_t  = int;
alias tcflag_t = int;

version (linux) {
	const int NCCS      = 32;
	const int TCSAFLUSH = 2;
	const int ICANON    = 2;
	const int VMIN      = 6;
	const int VTIME     = 5;
	const int TCSANOW   = 0;
	const int ECHO      = 8;
	const int BRKINT    = 2;
	const int ICRNL     = 256;
	const int INPCK     = 16;
	const int ISTRIP    = 32;
	const int IXON      = 1024;
	const int OPOST     = 48;
	const int IEXTEN    = 32768;
	const int ISIG      = 1;
	const int CS8       = 48;
}
else {
	// from FreeBSD values
	const int NCCS      = 20;
	const int TCSAFLUSH = 2;
	const int ICANON    = 256;
	const int VMIN      = 16;
	const int VTIME     = 17;
	const int TCSANOW   = 0;
	const int ECHO      = 8;
	const int BRKINT    = 2;
	const int ICRNL     = 256;
	const int INPCK     = 16;
	const int ISTRIP    = 32;
	const int IXON      = 512;
	const int OPOST     = 1;
	const int IEXTEN    = 1024;
	const int ISIG      = 128;
	const int CS8       = 768;
}

struct termios {
	tcflag_t   c_iflag;
	tcflag_t   c_oflag;
	tcflag_t   c_cflag;
	tcflag_t   c_lflag;
	ubyte      pad1;
	cc_t[NCCS] c_cc;
	speed_t    c_ispeed;
	speed_t    c_ospeed;
}

extern(C) int  tcgetattr(int, termios*);
extern(C) int  tcsetattr(int, int, termios*);
extern(C) void cfmakeraw(termios*);
extern(C) long read(int, void*, size_t);
