module noro.command;

import std.conv;
import std.format;
import std.string;

public import noro.app;

enum ArgType {
	String,
	Numeric
}

struct Command {
	void function(App, string[]) func;
	
	ArgType[] args;
}

class CommandException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

string[] SplitCommand(string cmd) {
	string[] ret;
	string   reading;
	bool     inString;

	foreach (ref ch ; cmd) {
		if (inString) {
			switch (ch) {
				case '"': {
					inString  = false;
					ret      ~= reading;
					reading   = "";
					break;
				}
				default: reading ~= ch;
			}
		}
		else {
			switch (ch) {
				case '"': {
					inString = true;
					break;
				}
				case ' ':
				case '\t': {
					if (reading.strip().length > 0) {
						ret ~= reading;
					}
					
					reading = "";
					break;
				}
				default: reading ~= ch;
			}
		}
	}

	if (inString || (reading.strip().length > 0)) {
		ret ~= reading;
	}

	return ret;
}

void RunCommand(ref Command[string] cmds, string name, string[] args) {
	if (!(name in cmds)) {
		throw new CommandException(format("No such command: %s", name));
	}

	auto cmd = cmds[name];

	void ThrowInvalidArgs() {
		string error = "Command expects: ";

		foreach (ref arg ; cmd.args) {
			error ~= text(arg) ~ ' ';
		}

		throw new CommandException(error.strip());
	}

	if (args.length != cmd.args.length) {
		throw new CommandException(
			format("Expected %d arguments, got %d", cmd.args.length, args.length)
		);
	}

	foreach (i, ref arg ; cmd.args) {
		if (arg == ArgType.Numeric) {
			if (!args[i].isNumeric()) {
				string error = "Command expects: ";

				foreach (ref arg2 ; cmd.args) {
					error ~= text(arg2) ~ ' ';
				}

				throw new CommandException(error.strip());
			}
		}
	}

	cmd.func(App.Instance(), args);
}
