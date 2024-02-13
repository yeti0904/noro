module noro.programs.page;

import std.range;
import noro.app;
import noro.theme;
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
		buf.attr = App.GetTheme().GetColour(ThemeColour.Window);
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
		buf.attr = App.GetTheme().GetColour(ThemeColour.Window);
		buf.SetFGColour(Colour16.Blue);
		buf.Print(text);
	}

	override void OnClick(PageProgram page) {
		onClick(page);
	}
}

class PageProgram : Program {
	Element[]   elements;
	size_t      caret;
	size_t      scroll;
	ThemeColour colours;

	this() {
		cursorVisible = true;
	}

	this(Element[] pelements) {
		elements      = pelements;
		colours       = ThemeColour.Window;
		cursorVisible = true;
	}

	override void Init() {
		parent.borderColour = colours;
	}

	override void Update() {
		
	}

	void LoadElements(Element[] pelements) {
		elements = pelements;
		caret    = 0;
		scroll   = 0;
	}

	void Scroll() { // TODO: completely broken!!
		long scaret  = cast(long) caret; // carrot hahaha
		long sscroll = cast(long) scroll;
		while (scaret - sscroll > parent.contents.GetSize().y - 1) {
			++ scroll;
			scaret  = cast(long) caret;
			sscroll = cast(long) scroll;
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
		buf.attr = App.GetTheme().GetColour(colours);
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
