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

static string defaultAutoexec = cast(string) import("runtime/autoexec");

void Config() {
	string homeFolder = environment.get("HOME");

	if (homeFolder is null) {
		stderr.writeln("your computer broken :(");
		exit(1);
	}

	string configFolder = format("%s/.config/noro", homeFolder);

	if (!exists(configFolder)) {
		mkdir(configFolder);
	}

	string autoexecPath = format("%s/autoexec", configFolder);

	if (!exists(autoexecPath)) {
		std.file.write(autoexecPath, defaultAutoexec);
	}

	auto app = App.Instance();

	foreach (i, ref line ; autoexecPath.readText().split("\n")) {
		try {
			app.RunCommand(line);
		}
		catch (CommandException e) {
			stderr.writefln("autoexec:%d: %s", i + 1, e.msg);
			exit(1);
		}
	}
}
