module noro.program;

public import noro.theme;
public import noro.types;
public import noro.ui.window;
public import noro.terminal.input;
public import noro.terminal.buffer;
public import noro.terminal.terminal;

class Program {
	UIWindow parent;
	bool     cursorVisible;

	abstract void Init();
	abstract void Update();
	abstract void Input(KeyPress key);
	abstract void OnResize(Vec2!ushort size);
	abstract void Render(Buffer buf);
}
