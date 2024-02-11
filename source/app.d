module noro.app;

import std.conv;
import std.file;
import std.array;
import std.stdio;
import std.range;
import std.format;
import std.string;
import std.datetime.stopwatch;
import noro.util;
import noro.theme;
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
import noro.debugging.keyTest;

import std.process : environment;

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

struct Workspace {
	UIManager ui;
}

class App {
	bool            running;
	Screen          screen;
	AppStatus       status;
	KeyPress        key;
	dchar           lastCommand;
	Command[string] commands;
	Shortcut[]      shortcuts;
	bool            shortcutsEnabled = true;
	Alert           alert;
	Theme           theme;
	Workspace[]     workspaces;
	size_t          workspace;

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

	static Theme GetTheme() {
		return App.Instance().theme;
	}

	static string GetNoroPath() {
		string homeFolder = environment.get("HOME");

		if (homeFolder is null) {
			stderr.writeln("your computer broken :(");
			exit(1);
		}

		string configFolder = format("%s/.config", homeFolder);

		if (!exists(configFolder)) {
			mkdir(configFolder);
		}

		configFolder ~= "/noro";

		if (!exists(configFolder)) {
			mkdir(configFolder);
		}

		return configFolder;
	}

	void Init() {
		running    = true;
		status     = AppStatus.Standby;
		screen     = new Screen();
		key        = KeyPress(' ', 0);
		theme      = new Theme();
		
		AllocateWorkspaces(10);

		commands = GetCommands();
		Config();
	}

	void AllocateWorkspaces(size_t amount) {
		workspaces = new Workspace[](amount);

		foreach (ref workspace ; workspaces) {
			workspace.ui = new UIManager();
		}
		
		workspace = 0;
	}

	UIManager GetUI() {
		return workspaces[workspace].ui;
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
		GetUI().Update();

		auto buffer = screen.buffer;
		buffer.SetBGColour(Colour16.Blue);
		buffer.SetFGColour(Colour16.BrightBlue);
		buffer.Clear(' ');

		// render top bar
		buffer.SetBGColour(Colour16.White);
		buffer.SetFGColour(Colour16.Black);
		buffer.HLine(0, 0, buffer.GetSize().x, ' ');
		buffer.caret = Vec2!ushort(0, 0);
		buffer.Printf("noro π - %s  |", status);

		foreach (i, ref iworkspace ; workspaces) {
			// idk why but i feel proud of the use of ternary here
			buffer.Printf(i == workspace? " [%d]" : " %d", i + 1);
		}

		string clock = ClockString();
		buffer.caret = Vec2!ushort(
			cast(ushort) (buffer.GetSize().x - clock.length - 1), 0
		);
		buffer.Print(clock);

		buffer.caret = Vec2!ushort(0, 0);

		// the comment below shows the downsides of using sed to refactor code
		// render GetUI()
		GetUI().Render(buffer);
		
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

		buffer.caret = Vec2!ushort(buffer.GetSize().x, 0);
		GetUI().SetCaret(buffer);
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
					GetUI().Input(input);
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
				auto screenSize = buffer.GetSize();

				switch (input.key) {
					case 'q': {
						status = AppStatus.Standby;
						break;
					}
					case Key.Up: {
						if ((input.mod & KeyMod.Shift) && (GetUI().Top().pos.y > 0)) {
							-- GetUI().Top().pos.y;
						}
						else if (GetUI().Top().pos.y >= 4) {
							GetUI().Top().pos.y -= 4;
						}
						break;
					}
					case Key.Down: {
						if (
							(input.mod & KeyMod.Shift) &&
							(GetUI().Top().pos.y < screenSize.y - 1)
						) {
							++ GetUI().Top().pos.y;
						}
						else if (GetUI().Top().pos.y < screenSize.y - 5) {
							GetUI().Top().pos.y += 4;
						}
						break;
					}
					case Key.Left: {
						if ((input.mod & KeyMod.Shift) && (GetUI().Top().pos.x > 0)) {
							-- GetUI().Top().pos.x;
						}
						else if (GetUI().Top().pos.x >= 4) {
							GetUI().Top().pos.x -= 4;
						}
						break;
					}
					case Key.Right: {
						if (
							(input.mod & KeyMod.Shift) &&
							(GetUI().Top().pos.x < screenSize.x - 1)
						) {
							++ GetUI().Top().pos.x;
						}
						else if (GetUI().Top().pos.x < screenSize.x - 5) {
							GetUI().Top().pos.x += 4;
						}
						break;
					}
					case 'w': {
						auto size = GetUI().Top().GetSize();

						if (size.y > 8) {
							size.y -= 4;
							GetUI().Top().Resize(size.x, size.y);
						}
						break;
					}
					case 'a': {
						auto size = GetUI().Top().GetSize();

						if (size.x > 8) {
							size.x -= 4;
							GetUI().Top().Resize(size.x, size.y);
						}
						break;
					}
					case 's': {
						auto size = GetUI().Top().GetSize();
						size.y += 4;
						GetUI().Top().Resize(size.x, size.y);
						break;
					}
					case 'd': {
						auto size = GetUI().Top().GetSize();
						size.x += 4;
						GetUI().Top().Resize(size.x, size.y);
						break;
					}
					case 'W': {
						auto size = GetUI().Top().GetSize();

						if (size.y > 5) {
							-- size.y;
							GetUI().Top().Resize(size.x, size.y);
						}
						break;
					}
					case 'A': {
						auto size = GetUI().Top().GetSize();

						if (size.x > 5) {
							-- size.x;
							GetUI().Top().Resize(size.x, size.y);
						}
						break;
					}
					case 'S': {
						auto size = GetUI().Top().GetSize();
						++ size.y;
						GetUI().Top().Resize(size.x, size.y);
						break;
					}
					case 'D': {
						auto size = GetUI().Top().GetSize();
						++ size.x;
						GetUI().Top().Resize(size.x, size.y);
						break;
					}
					default: break; // TODO: error
				}

				break;
			}
		}
	}
}

const string appHelp = "
Usage: %s [FLAGS]

Flags:
	--help    : Show this help message
	--keyTest : Runs the keyTest debugging program
";

int main(string[] args) {
	for (size_t i = 1; i < args.length; ++ i) {
		if (args[i][0] == '-') {
			switch (args[i]) {
				case "--help": {
					writefln(appHelp.strip(), args[0]);
					return 0;
				}
				case "--keyTest": {
					KeyTestProgram();
					return 0;
				}
				default: {
					stderr.writefln("Unrecognised flag '%s'", args[i]);
					return 1;
				}
			}
		}
		else {
			// idk
		}
	}

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
		return 1;
	}

	return 0;
}
