module noro.app;

import std.stdio;
import std.range;
import noro.types;
import noro.uiManager;
import noro.ui.window;
import noro.pages.menu;
import noro.programs.page;
import noro.terminal.input;
import noro.terminal.screen;

enum AppStatus {
	Standby,
	Command,
	Window
}

class App {
	bool      running;
	Screen    screen;
	UIManager ui;
	AppStatus status;
	KeyPress  key;

	this() {
		running = true;
		screen  = new Screen();
		ui      = new UIManager();

		status = AppStatus.Standby;
	}

	static App Instance() {
		static App app;

		if (!app) {
			app = new App();
		}

		return app;
	}

	void Update() {
		// update
		ui.Update();
		
		auto buffer = screen.buffer;
		buffer.SetBGColour(Colour16.Blue);
		buffer.SetFGColour(Colour16.BrightBlue);
		buffer.Clear(' ');

		// render top bar
		buffer.SetBGColour(Colour16.White);
		buffer.SetFGColour(Colour16.Black);
		buffer.HLine(0, 0, buffer.GetSize().x, ' ');
		buffer.caret = Vec2!ushort(0, 0);
		buffer.Printf("noro π - %s", status);

		// render UI
		ui.Render(buffer);

		buffer.caret = Vec2!ushort(buffer.GetSize().x, 0);
		ui.SetCaret(buffer);
		screen.Render();

		auto input = GetKey();
		key = input;

		if ((input.mod == KeyMod.Ctrl) && (input.key == 'q')) {
			running = false;
			return;
		}
		
		final switch (status) {
			case AppStatus.Standby: {
				if ((input.mod == KeyMod.Ctrl) && (input.key == 'k')) {
					status = AppStatus.Command;
				}
				else {
					ui.Input(input);
				}

				break;
			}
			case AppStatus.Command: {
				switch (input.key) {
					case 'm': {
						status = AppStatus.Window;
						break;
					}
					case 'f': {
						ui.Top().pos = Vec2!ushort(0, 1);
						ui.Top().Resize(
							buffer.GetSize().x, cast(ushort) (buffer.GetSize().y - 1)
						);
						break;
					}
					case 'F': {
						ui.Top().pos = Vec2!ushort(0, 0);
						ui.Top().Resize(buffer.GetSize().x, buffer.GetSize().y);
						break;
					}
					case 'b': {
						if (!(cast(UIWindow) ui.Top())) break;

						auto win   = cast(UIWindow) ui.Top();
						win.border = !win.border;
						win.Resize(win.GetSize().x, win.GetSize().y);
						break;
					}
					case 'a': {
						auto window    = new UIWindow(50, 20);
						window.pos     = Vec2!ushort(0, 1);
						window.name    = "Menu";
						window.program = new PageProgram(MenuPage());
						ui.Add(window);
						break;
					}
					case 'q': {
						if (ui.elements.empty) {
							running = false;
							return;
						}
						ui.DeleteTop();
						break;
					}
					case Key.Tab: {
						if (ui.elements.length < 2) break;

						ui.MoveTop(0);
						break;
					}
					default: {
						status = AppStatus.Standby;
						break; // TODO: error
					}
				}

				if (status == AppStatus.Command) {
					status = AppStatus.Standby;
				}

				break;
			}
			case AppStatus.Window: {
				switch (input.key) {
					case 'q': {
						status = AppStatus.Standby;
						break;
					}
					case Key.Up: {
						if (input.mod & KeyMod.Shift) {
							-- ui.Top().pos.y;
						}
						else {
							ui.Top().pos.y -= 4;
						}
						break;
					}
					case Key.Down: {
						if (input.mod & KeyMod.Shift) {
							++ ui.Top().pos.y;
						}
						else {
							ui.Top().pos.y += 4;
						}
						break;
					}
					case Key.Left: {
						if (input.mod & KeyMod.Shift) {
							-- ui.Top().pos.x;
						}
						else {
							ui.Top().pos.x -= 4;
						}
						break;
					}
					case Key.Right: {
						if (input.mod & KeyMod.Shift) {
							++ ui.Top().pos.x;
						}
						else {
							ui.Top().pos.x += 4;
						}
						break;
					}
					case 'w': {
						auto size = ui.Top().GetSize();
						size.y -= 4;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'a': {
						auto size = ui.Top().GetSize();
						size.x -= 4;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 's': {
						auto size = ui.Top().GetSize();
						size.y += 4;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'd': {
						auto size = ui.Top().GetSize();
						size.x += 4;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'W': {
						auto size = ui.Top().GetSize();
						-- size.y;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'A': {
						auto size = ui.Top().GetSize();
						-- size.x;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'S': {
						auto size = ui.Top().GetSize();
						++ size.y;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					case 'D': {
						auto size = ui.Top().GetSize();
						++ size.x;
						ui.Top().Resize(size.x, size.y);
						break;
					}
					default: break; // TODO: error
				}

				break;
			}
		}
	}
}

void main() {
	auto app = App.Instance();

	while (app.running) {
		app.Update();
	}
}
