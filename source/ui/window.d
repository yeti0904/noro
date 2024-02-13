module noro.ui.window;

import noro.app;
import noro.theme;
import noro.program;
import noro.ui.base;

class UIWindow : UIBase {
	ThemeColour borderColour;
	Buffer      contents;
	Program     program;
	string      name;
	bool        border;
	bool        wasInit;

	this(ushort w, ushort h) {
		border       = true;
		borderColour = ThemeColour.Window;
		buffer       = new Buffer(Vec2!ushort(w, h));
		contents     = new Buffer(Vec2!ushort(cast(ushort) (w - 2), cast(ushort) (h - 2)));
		resizable    = true;
	}

	private void InitProgram() {
		if (!wasInit) {
			program.parent = this;
			program.Init();
			wasInit = true;
		}
	}

	override void Update() {
		if (program) {
			InitProgram();
			program.parent = this;
			program.Update();
		}
	}

	override void Render(bool focused) {
		program.parent = this;
		buffer.Clear(' ');
		
		if (program) {
			InitProgram();
			program.Render(contents);
		}
		
		if (border) {
			buffer.BlitBuffer(contents, 1, 1);
		}
		else {
			buffer.BlitBuffer(contents, 0, 0);
		}

		dchar cornerUR = focused? Character.DCornerUR : Character.CornerUR;
		dchar cornerUL = focused? Character.DCornerUL : Character.CornerUL;
		dchar cornerLL = focused? Character.DCornerLL : Character.CornerLL;
		dchar cornerLR = focused? Character.DCornerLR : Character.CornerLR;
		dchar hLine    = focused? Character.DHLine    : Character.HLine;
		dchar vLine    = focused? Character.DVLine    : Character.VLine;

		// corners
		if (!border) {
			buffer.caret = contents.caret;
			return;
		}
		
		buffer.attr = App.GetTheme().GetColour(borderColour);
		buffer.Print(0, 0, cornerUL);
		buffer.Print(cast(ushort) (buffer.GetSize().x - 1), 0, cornerUR);
		buffer.Print(0, cast(ushort) (buffer.GetSize().y - 1), cornerLL);
		buffer.Print(
			cast(ushort) (buffer.GetSize().x - 1), cast(ushort) (buffer.GetSize().y - 1),
			cornerLR
		);

		// sides
		buffer.HLine(1, 0, cast(ushort) (buffer.GetSize().x - 2), hLine);
		buffer.HLine(
			1, cast(ushort) (buffer.GetSize().y - 1),
			cast(ushort) (buffer.GetSize().x - 2), hLine
		);
		buffer.VLine(0, 1, cast(ushort) (buffer.GetSize().y - 2), vLine);
		buffer.VLine(
			cast(ushort) (buffer.GetSize().x - 1), 1,
			cast(ushort) (buffer.GetSize().y - 2), vLine
		);

		// window title
		buffer.caret = Vec2!ushort(
			cast(ushort) ((buffer.GetSize().x / 2) - (name.length / 2)), 0
		);
		buffer.Print(name);

		buffer.caret = Vec2!ushort(
			cast(ushort) (contents.caret.x + 1), cast(ushort) (contents.caret.y + 1)
		);
	}

	override void Input(KeyPress key) {
		if (program) {
			InitProgram();
			program.parent = this;
			program.Input(key);
		}
	}

	override void Resize(ushort w, ushort h) {
		buffer.Resize(w, h);

		if (border) {
			contents.Resize(cast(ushort) (w - 2), cast(ushort) (h - 2));
		}
		else {
			contents.Resize(w, h);
		}

		if (program) {
			program.OnResize(Vec2!ushort(w, h));
		}
	}

	override Vec2!ushort GetSize() {
		return buffer.GetSize();
	}

	override bool CursorVisible() {
		if (program is null) {
			return false;
		}

		return program.cursorVisible;
	}
}
