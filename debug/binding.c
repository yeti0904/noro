#include <stdio.h>
#include <termios.h>
#include <sys/ioctl.h>

int main(void) {
	struct winsize winSize;
	void*          ptr = &winSize;
	puts("winsize structure from ioctl");
	printf("ws_row    = %d\n", (int) ((void*) &winSize.ws_row    - ptr));
	printf("ws_col    = %d\n", (int) ((void*) &winSize.ws_col    - ptr));
	printf("ws_xpixel = %d\n", (int) ((void*) &winSize.ws_xpixel - ptr));
	printf("ws_ypixel = %d\n", (int) ((void*) &winSize.ws_ypixel - ptr));

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
	printf("c_iflag  = %d\n", (int) ((void*) &termiosStruct.c_iflag  - ptr));
	printf("c_oflag  = %d\n", (int) ((void*) &termiosStruct.c_oflag  - ptr));
	printf("c_cflag  = %d\n", (int) ((void*) &termiosStruct.c_cflag  - ptr));
	printf("c_lflag	 = %d\n", (int) ((void*) &termiosStruct.c_lflag  - ptr));
	printf("c_cc     = %d\n", (int) ((void*) &termiosStruct.c_cc     - ptr));
	printf("c_ispeed = %d\n", (int) ((void*) &termiosStruct.c_ispeed - ptr));
	printf("c_ospeed = %d\n", (int) ((void*) &termiosStruct.c_ospeed - ptr));
	return 0;
}
