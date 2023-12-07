module noro.app;

import std.stdio;
import noro.terminal.screen;
import noro.terminal.input;

class App {
	bool   running;
	Screen screen;

	this() {
		running = true;
		screen  = new Screen();
	}

	static App Instance() {
		App app;

		if (!app) {
			app = new App();
		}

		return app;
	}

	void Update() {
		screen.buffer.SetBGColour(Colour16.Blue);
		screen.buffer.Clear(' ');
		screen.Render();

		auto input = GetKey();

		if (input.ctrl && (input.key == 'q')) {
			running = false;
			return;
		}
	}
}

void main() {
	auto app = App.Instance();

	while (app.running) {
		app.Update();
	}
}
