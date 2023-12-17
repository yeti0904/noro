module noro.app;

import std.conv;
import std.array;
import std.stdio;
import std.range;
import std.format;
import std.datetime.stopwatch;
import noro.types;
import noro.config;
import noro.command;
import noro.commands;
import noro.shortcuts;
import noro.uiManager;
import noro.ui.window;
import noro.pages.menu;
import noro.programs.page;
import noro.terminal.input;
import noro.terminal.screen;
import noro.terminal.terminal;

enum AppStatus {
	Standby,
	Shortcut,
	Window
}

struct Alert {
	bool      active;
	StopWatch sw;
	int       activeTime; // seconds
	string    contents;
}

class App {
	bool            running;
	Screen          screen;
	UIManager       ui;
	AppStatus       status;
	KeyPress        key;
	dchar           lastCommand;
	Command[string] commands;
	Shortcut[]      shortcuts;
	bool            shortcutsEnabled = true;
	Alert           alert;

	private bool init;

	this() {
		
	}

	static App Instance() {
		static App app;

		if (!app) {
			app = new App();
		}

		return app;
	}

	void Init() {
		running = true;
		status  = AppStatus.Standby;
		screen  = new Screen();
		ui      = new UIManager();
		key     = KeyPress(' ', 0);

		commands = GetCommands();
		Config();
	}

	void RunCommand(string cmd) {
		auto parts = SplitCommand(cmd);

		if (parts.empty) return;
		commands.RunCommand(parts[0], parts[1 .. $]);
	}

	bool IsShortcut(KeyPress key) {
		foreach (ref sc ; shortcuts) {
			if (sc.key == key) return true;
		}

		return false;
	}

	void RunShortcut(KeyPress key) {
		foreach (ref sc ; shortcuts) {
			if (sc.key == key) {
				RunCommand(sc.cmd);
				return;
			}
		}

		assert(0);
	}

	void NewAlert(string msg, int duration) {
		alert = Alert(true, StopWatch(AutoStart.yes), duration, msg);
	}

	void Update() {
		// update
		ui.Update();

		auto buffer = screen.buffer;
		buffer.SetBGColour(Colour16.Blue);
		buffer.SetFGColour(Colour16.BrightBlue);
		buffer.Clear(' ');
		
		// update alert
		if (alert.active) {
			if (alert.sw.peek.total!("seconds") > alert.activeTime) {
				alert.active = false;
			}
			else {
				string alertText = format("[ %s ]", alert.contents);

				buffer.caret = Vec2!ushort(
					cast(ushort) ((buffer.GetSize().x / 2) - (alertText.length / 2)),
					cast(ushort) (buffer.GetSize().y / 2)
				);
				buffer.SetBGColour(Colour16.Green);
				buffer.SetFGColour(Colour16.Black);
				buffer.Print(alertText);
			}
		}

		// render top bar
		buffer.SetBGColour(Colour16.White);
		buffer.SetFGColour(Colour16.Black);
		buffer.HLine(0, 0, buffer.GetSize().x, ' ');
		buffer.caret = Vec2!ushort(0, 0);
		buffer.Printf("noro π - %s", status);
		buffer.caret = Vec2!ushort(cast(ushort) (buffer.GetSize().x - 2), 0);
		buffer.Printf("%c", lastCommand);

		// render UI
		ui.Render(buffer);

		buffer.caret = Vec2!ushort(buffer.GetSize().x, 0);
		ui.SetCaret(buffer);
		screen.Render();

		auto input = GetKey();

		if (input.key == Key.Null) {
			return;
		}
		
		key = input;

		if ((input.mod == KeyMod.Ctrl) && (input.key == 'q')) {
			running = false;
			return;
		}
		
		final switch (status) {
			case AppStatus.Standby: {
				if (shortcutsEnabled && (input.mod == KeyMod.Ctrl) && (input.key == 'k')) {
					status = AppStatus.Shortcut;
				}
				else {
					ui.Input(input);
				}

				break;
			}
			case AppStatus.Shortcut: {
				auto oldLastCommand = lastCommand;
				lastCommand         = input.key;

				if (!IsShortcut(input)) {
					// TODO: error on no shortcut
					status = AppStatus.Standby;
					break;
				}

				RunShortcut(input);

				if (status == AppStatus.Shortcut) {
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
	try {
		auto app = App.Instance();
		app.Init();

		while (app.running) {
			app.Update();
		}
	}
	catch (Exception e) {
		Terminal.SetAltBuffer(false);
		Terminal.SetRawMode(false);
		Terminal.SetEcho(true);
		stderr.writeln(text(e).replace("\n", "\r\n"));
	}
}
