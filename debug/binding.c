#include <stdio.h>
#include <termios.h>
#include <sys/ioctl.h>

int main(void) {
	struct winsize winSize;
	void*          ptr = &winSize;
	puts("winsize structure from ioctl");
	printf("ws_row    = %d\n", (int) (ptr - (void*) &winSize.ws_row));
	printf("ws_col    = %d\n", (int) (ptr - (void*) &winSize.ws_col));
	printf("ws_xpixel = %d\n", (int) (ptr - (void*) &winSize.ws_xpixel));
	printf("ws_ypixel = %d\n", (int) (ptr - (void*) &winSize.ws_ypixel));

	puts("\nioctl constants");
	printf("TIOCGWINSZ = %d\n", TIOCGWINSZ);

	puts("\ntermios type sizes");
	printf("sizeof(cc_t) = %d\n", sizeof(cc_t));
	printf("sizeof(speed_t) = %d\n", sizeof(speed_t));
	printf("sizeof(tcflag_t) = %d\n", sizeof(tcflag_t));

	puts("\ntermios consts");
	printf("NCCS      = %d\n", NCCS);
	printf("TCSAFLUSH = %d\n", TCSAFLUSH);
	printf("ICANON    = %d\n", ICANON);
	printf("VMIN      = %d\n", VMIN);
	printf("VTIME     = %d\n", VTIME);
	printf("TCSANOW   = %d\n", TCSANOW);
	printf("ECHO      = %d\n", ECHO);
	printf("BRKINT    = %d\n", BRKINT);
	printf("ICRNL     = %d\n", ICRNL);
	printf("INPCK     = %d\n", INPCK);
	printf("ISTRIP    = %d\n", ISTRIP);
	printf("IXON      = %d\n", IXON);
	printf("OPOST     = %d\n", OPOST);
	printf("IEXTEN    = %d\n", IEXTEN);
	printf("ISIG      = %d\n", ISIG);
	printf("CS8       = %d\n", CS8);

	puts("\ntermios structure");
	struct termios termiosStruct;
	ptr = &termiosStruct;
	printf("c_iflag  = %d\n", (int) (ptr - (void*) &termiosStruct.c_iflag));
	printf("c_oflag  = %d\n", (int) (ptr - (void*) &termiosStruct.c_oflag));
	printf("c_cflag  = %d\n", (int) (ptr - (void*) &termiosStruct.c_cflag));
	printf("c_lflag	 = %d\n", (int) (ptr - (void*) &termiosStruct.c_lflag));
	printf("c_cc     = %d\n", (int) (ptr - (void*) &termiosStruct.c_cc));
	printf("c_ispeed = %d\n", (int) (ptr - (void*) &termiosStruct.c_ispeed));
	printf("c_ospeed = %d\n", (int) (ptr - (void*) &termiosStruct.c_ospeed));
	return 0;
}
