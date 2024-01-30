module noro.programs.selection;

import noro.app;
import noro.types;
import noro.theme;
import noro.program;

class SelectionProgram : Program {
	string      msg;
	string[]    options;
	size_t      caret;
	Program     program;
	ThemeColour colours;

	void delegate(Program, string) onComplete;

	this(string pmsg) {
		msg = pmsg;
	}

	this(
		string pmsg, string[] poptions, void delegate(Program, string) pfunc,
		Program pprogram
	) {
		msg        = pmsg;
		onComplete = pfunc;
		options    = poptions;
		program    = pprogram;
		colours    = ThemeColour.Dialog;
	}

	override void Init() {
		parent.borderColour = colours;
	}

	override void Update() {
		
	}

	override void Input(KeyPress key) {
		if (key.mod > 0) return;

		switch (key.key) {
			case Key.Up: {
				if (caret > 0) -- caret;
				break;
			}
			case Key.Down: {
				if (caret < options.length - 1) ++ caret;
				break;
			}
			case ' ':
			case '\n': {
				onComplete(program, options[caret]);
				App.Instance().ui.DeleteTop(); // TODO: idk look at input.d
				break;
			}
			default: break;
		}
	}

	override void OnResize(Vec2!ushort size) {
		
	}

	override void Render(Buffer buf) {
		auto theme = App.GetTheme().GetColour(colours);

		buf.attr = theme;
		buf.Clear(' ');

		buf.caret = Vec2!ushort(0, 0);
		buf.Print(msg);

		ushort optionStart = cast(ushort) (buf.GetSize().y - options.length);

		foreach (i, ref option ; options) {
			buf.caret.y = cast(ushort) (optionStart + i);

			if (i == caret) {
				buf.attr = theme.Invert();
				buf.HLine(0, buf.caret.y, cast(ushort) (buf.GetSize().x - 1), ' ');
			}
			else {
				buf.attr = theme;
			}

			buf.caret.x = cast(ushort) ((buf.GetSize().x / 2) - (option.length / 2));
			buf.Print(option);
		}

		buf.caret.x = cast(ushort) (buf.GetSize().x - 1);
		buf.caret.y = cast(ushort) (optionStart + caret);
	}
}
