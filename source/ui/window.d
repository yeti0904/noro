module noro.ui.window;

import noro.program;
import noro.ui.base;

class UIWindow : UIBase {
	Colour16 borderFG;
	Colour16 borderBG;
	Buffer   contents;
	Program  program;
	string   name;
	bool     border;

	this(ushort w, ushort h) {
		border   = true;
		borderFG = Colour16.White;
		borderBG = Colour16.Black;
		buffer   = new Buffer(Vec2!ushort(w, h));
		contents = new Buffer(Vec2!ushort(cast(ushort) (w - 2), cast(ushort) (h - 2)));
	}

	override void Update() {
		if (program) {
			program.Update();
		}
	}

	override void Render() {
		buffer.Clear(' ');
		if (program) {
			program.Render(contents);
		}
	
		buffer.BlitBuffer(contents, 1, 1);

		dchar cornerUR = focused? Character.DCornerUR : Character.CornerUR;
		dchar cornerUL = focused? Character.DCornerUL : Character.CornerUL;
		dchar cornerLL = focused? Character.DCornerLL : Character.CornerLL;
		dchar cornerLR = focused? Character.DCornerLR : Character.CornerLR;
		dchar hLine    = focused? Character.DHLine    : Character.HLine;
		dchar vLine    = focused? Character.DVLine    : Character.VLine;

		// corners
		buffer.SetBGColour(borderBG);
		buffer.SetFGColour(borderFG);
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
			program.Input(key);
		}
	}

	override void Resize(ushort w, ushort h) {
		buffer.Resize(w, h);
		contents.Resize(cast(ushort) (w - 2), cast(ushort) (h - 2));
	}

	override Vec2!ushort GetSize() {
		return buffer.GetSize();
	}
}
