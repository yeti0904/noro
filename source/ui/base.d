module noro.ui.base;

public import noro.types;
public import noro.terminal.input;
public import noro.terminal.buffer;

class UIBase {
	Vec2!ushort pos;
	Buffer      buffer;
	bool        resizable;
	bool        focused;
	
	abstract void        Update();
	abstract void        Render();
	abstract void        Input(KeyPress key);
	abstract void        Resize(ushort w, ushort h);
	abstract Vec2!ushort GetSize();
}
