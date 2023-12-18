module noro.programs.page;

import std.range;
import noro.app;
import noro.types;
import noro.program;

enum ElementType {
	Text,
	Link
}

class Element {
	ElementType type;

	abstract void Render(Buffer buf);
	abstract void OnClick(PageProgram page);
}

class TextElement : Element {
	string contents;

	this() {
		type = ElementType.Text;
	}

	this(string pcontents) {
		type     = ElementType.Text;
		contents = pcontents;
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(Colour16.Black);
		buf.SetFGColour(Colour16.White);
		buf.Print(contents);
	}

	override void OnClick(PageProgram page) {
		
	}
}

class LinkElement : Element {
	string text;
	
	void function(PageProgram page) onClick;

	this() {
		type = ElementType.Link;
	}

	this(string ptext, void function(PageProgram page) ponClick) {
		type    = ElementType.Text;
		text    = ptext;
		onClick = ponClick;
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(Colour16.Black);
		buf.SetFGColour(Colour16.Blue);
		buf.Print(text);
	}

	override void OnClick(PageProgram page) {
		onClick(page);
	}
}

class PageProgram : Program {
	Element[] elements;
	size_t    caret;
	size_t    scroll;

	this() {
		
	}

	this(Element[] pelements) {
		elements = pelements;
	}

	override void Init() {
		parent.borderBG = &App.GetTheme().window.fg.byteColour;
		parent.borderFG = &App.GetTheme().window.bg.byteColour;
	}

	override void Update() {
		
	}

	void Scroll() { // TODO: completely broken!!
		while (caret - scroll > parent.contents.GetSize().x) {
			++ scroll;
		}
	
		if (caret < scroll) {
			scroll = caret;
		}
	}

	override void Input(KeyPress key) {
		auto bufSize = parent.contents.GetSize();
	
		if (key.mod == 0) {
			switch (key.key) {
				case Key.Up: {
					if (caret > 0) {
						-- caret;
						Scroll();
					}
					break;
				}
				case Key.Down: {
					if (caret < elements.length) {
						++ caret;
						Scroll();
					}
					break;
				}
				case ' ': {
					if (elements.empty) return;

					elements[caret].OnClick(this);
					break;
				}
				default: break;
			}
		}
	}

	override void OnResize(Vec2!ushort size) {
		Scroll();
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(cast(Colour16) App.GetTheme().window.fg.byteColour);
		buf.SetFGColour(cast(Colour16) App.GetTheme().window.bg.byteColour);
		buf.Clear(' ');
		
		buf.caret = Vec2!ushort(0, 0);
		foreach (ref elem ; elements[scroll .. $]) {
			elem.Render(buf);
			++ buf.caret.y;
			buf.caret.x = 0;
		}

		buf.caret = Vec2!ushort(0, cast(ushort) (caret - scroll));
	}
}
