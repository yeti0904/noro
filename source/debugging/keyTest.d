module noro.debugging.keyTest;

import noro.types;
import noro.terminal.input;
import noro.terminal.screen;
import noro.terminal.buffer;

void KeyTestProgram() {
	auto screen = new Screen();
	SetInputBlocks(true);

	char input = ' ';
	screen.buffer.Print(
		"Noro key tester\nPress 'q' to quit, 'c' to clear, 'i' for ignore mode\n"
	);

	bool ignore = false;

	while (true) {
		screen.Render();
		input = GetChar();

		if (ignore) {
			screen.buffer.Printf("%c (%d)\n", input, input);
		}
		else {
			switch (input) {
				case 'q': return;
				case 'c': {
					screen.buffer.Clear(' ');
					screen.buffer.caret = Vec2!ushort(0, 0);
					break;
				}
				case 'i': {
					ignore = true;
					break;
				}
				default: {
					screen.buffer.Printf("%c (%d)\n", input, input);
				}
			}
		}
	}
}
