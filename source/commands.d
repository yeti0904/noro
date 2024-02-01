module noro.commands;

import std.utf;
import std.conv;
import std.file;
import std.json;
import std.range;
import std.format;
import noro.util;
import noro.theme;
import noro.types;
import noro.command;
import noro.shortcuts;
import noro.ui.window;
import noro.pages.menu;
import noro.programs.page;
import noro.programs.editor;

private void WindowMode(App app, string[] args) {
	app.status = AppStatus.Window;
}

private void Maximise(App app, string[] args) {
	auto buffer = app.screen.buffer;
	
	app.GetUI().Top().pos = Vec2!ushort(0, 1);
	app.GetUI().Top().Resize(buffer.GetSize().x, cast(ushort) (buffer.GetSize().y - 1));
}

private void FullScreen(App app, string[] args) {
	auto buffer = app.screen.buffer;
	
	app.GetUI().Top().pos = Vec2!ushort(0, 0);
	app.GetUI().Top().Resize(buffer.GetSize().x, buffer.GetSize().y);
}

private void Border(App app, string[] args) {
	if (!(cast(UIWindow) app.GetUI().Top())) return;

	auto win   = cast(UIWindow) app.GetUI().Top();
	win.border = !win.border;
	win.Resize(win.GetSize().x, win.GetSize().y);
}

private void Menu(App app, string[] args) {
	auto window           = new UIWindow(50, 20);
	window.pos            = Vec2!ushort(0, 1);
	window.name           = "Menu";
	window.program        = new PageProgram(MenuPage());
	window.program.parent = window;
	app.GetUI().Add(window);
}

private void Close(App app, string[] args) {
	if (app.GetUI().elements.empty) {
		app.running = false;
		return;
	}
	
	app.GetUI().DeleteTop();
}

private void Switch(App app, string[] args) {
	if (app.GetUI().elements.length < 2) return;

	app.GetUI().MoveTop(0);
}

private void NewShortcut(App app, string[] args) {
	auto keys = args[0];
	auto cmd  = args[1];

	app.shortcuts ~= Shortcut(ParseKey(keys), cmd);
}

private void Editor(App app, string[] args) {
	if (!(cast(UIWindow) app.GetUI().Top())) return;

	auto win           = cast(UIWindow) app.GetUI().Top();
	win.program        = new EditorProgram();
	win.program.parent = win;
}

private void DisableShortcuts(App app, string[] args) {
	app.shortcutsEnabled = false;
}

private void SetTheme(App app, string[] args) {
	auto path = Theme.Path(args[0]);

	if (!exists(path)) {
		app.NewAlert("No such theme exists", 3);
		return;
	}

	JSONValue theme;

	try {
		theme = parseJSON(readText(path));
	}
	catch (JSONException e) {
		app.NewAlert(format("JSON error: %s", e.msg), 3);
		return;
	}
	catch (FileException e) {
		app.NewAlert("Failed to read theme file", 3);
		return;
	}
	catch (UTFException e) {
		app.NewAlert("Theme file has invalid unicode", 3);
		return;
	}

	app.theme.Load(theme);
}

private void RunCommand(App app, string[] args) {
	CreateInputWindow(
		null, "Command", "Type a command", (Program, string input) {
			App.Instance().RunCommand(input);
		}
	);
}

private void SetWorkspaces(App app, string[] args) {
	size_t amount = parse!size_t(args[0]);

	if (amount == 0) {
		app.NewAlert("At least 1 workspace must be allocated", 3);
		return;
	}

	app.AllocateWorkspaces(10);
}

private void SetWorkspace(App app, string[] args) {
	size_t which = parse!size_t(args[0]);

	if ((which > app.workspaces.length) || (which == 0)) {
		app.NewAlert("Workspace index out of bounds", 3);
		return;
	}

	app.workspace = which - 1;
}

Command[string] GetCommands() {
	Command[string] ret;

	ret["window"]         = Command(&WindowMode,       []);
	ret["maximise"]       = Command(&Maximise,         []);
	ret["fullscreen"]     = Command(&FullScreen,       []);
	ret["border"]         = Command(&Border,           []);
	ret["menu"]           = Command(&Menu,             []);
	ret["close"]          = Command(&Close,            []);
	ret["switch"]         = Command(&Switch,           []);
	ret["shortcut"]       = Command(&NewShortcut,      [ArgType.String, ArgType.String]);
	ret["editor"]         = Command(&Editor,           []);
	ret["shortcuts_off"]  = Command(&DisableShortcuts, []);
	ret["theme"]          = Command(&SetTheme,         [ArgType.String]);
	ret["command"]        = Command(&RunCommand,       []);
	ret["set_workspaces"] = Command(&SetWorkspaces,    [ArgType.Numeric]);
	ret["set_workspace"]  = Command(&SetWorkspace,     [ArgType.Numeric]);

	return ret;
}
