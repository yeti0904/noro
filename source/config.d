module noro.config;

import std.file;
import std.array;
import std.stdio;
import std.range;
import std.format;
import std.process;
import std.algorithm;
import core.stdc.stdlib;
import noro.app;
import noro.command;
import noro.terminal.terminal;

static private string defaultAutoexec = cast(string) import("runtime/autoexec.noro");

// themes
struct ThemePair {
	string path;
	string contents;
}

static private const ThemePair[] themes = [
	ThemePair("%s/default.json", cast(string) import("runtime/themes/default.json")),
	ThemePair("%s/light.json", cast(string) import("runtime/themes/light.json"))
];

void Config() {
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

	string themesFolder = format("%s/themes", configFolder);

	if (!exists(themesFolder)) {
		mkdir(themesFolder);
	}

	foreach (theme ; themes) {
		auto path = format(theme.path, themesFolder);

		if (!exists(path)) {
			std.file.write(path, theme.contents);
		}
	}

	string autoexecPath = format("%s/autoexec.noro", configFolder);

	if (!exists(autoexecPath)) {
		std.file.write(autoexecPath, defaultAutoexec);
	}

	auto app = App.Instance();

	foreach (i, ref line ; autoexecPath.readText().split("\n")) {
		try {
			app.RunCommand(line);
		}
		catch (CommandException e) {
			Terminal.SetAltBuffer(false);
			Terminal.SetRawMode(false);
			Terminal.SetEcho(true);
			stderr.writefln("autoexec:%d: %s", i + 1, e.msg);
			exit(1);
		}
	}
}
