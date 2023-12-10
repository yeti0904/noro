module noro.programs.page;

import std.range;
import noro.types;
import noro.program;

enum ElementType {
	Text,
	Link
}

class Element {
	ElementType type;

	abstract void Render(Buffer buf);
	abstract void OnClick();
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

	override void OnClick() {
		
	}
}

class LinkElement : Element {
	string          text;
	void function() onClick;

	this() {
		type = ElementType.Link;
	}

	this(string ptext, void function() ponClick) {
		type    = ElementType.Text;
		text    = ptext;
		onClick = ponClick;
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(Colour16.Black);
		buf.SetFGColour(Colour16.Blue);
		buf.Print(text);
	}

	override void OnClick() {
		onClick();
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
		parent.borderBG = Colour16.Black;
		parent.borderFG = Colour16.White;
	}

	override void Update() {
		
	}

	override void Input(KeyPress key) {
		auto bufSize = parent.contents.GetSize();
	
		if (key.mod == 0) {
			switch (key.key) {
				case Key.Up: {
					if (caret > 0) {
						-- caret;

						auto scaret  = cast(long) caret;
						auto sscroll = cast(long) scroll;

						while (scaret - sscroll < 0) {
							-- scroll;
							sscroll = cast(long) scroll;
						}
					}
					break;
				}
				case Key.Down: {
					if (caret < elements.length - 1) {
						++ caret;

						while (caret - scroll > bufSize.y - 1) {
							++ scroll;
						}
					}
					break;
				}
				case ' ': {
					if (elements.empty) return;

					elements[caret].OnClick();
					break;
				}
				default: break;
			}
		}
	}

	override void Render(Buffer buf) {
		buf.SetBGColour(Colour16.Black);
		buf.SetFGColour(Colour16.White);
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
