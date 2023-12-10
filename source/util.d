module noro.util;

import noro.app;
import noro.types;
import noro.ui.window;
import noro.programs.input;
import noro.terminal.buffer;

void CreateInputWindow(string title, string msg, void delegate(string) func) {
	auto app = App.Instance();

	auto window     = new UIWindow(20, 5);
	window.name     = title;
	window.program  = new InputProgram(msg, func);
	window.borderBG = Colour16.White;
	window.borderFG = Colour16.Black;
	
	window.pos = Vec2!ushort(
		cast(ushort) ((app.screen.buffer.GetSize().x / 2) - (window.GetSize().x / 2)),
		cast(ushort) ((app.screen.buffer.GetSize().y / 2) - (window.GetSize().y / 2))
	);

	app.ui.Add(window);
}
