module noro.program;

public import noro.ui.window;
public import noro.terminal.input;
public import noro.terminal.buffer;

class Program {
	UIWindow parent;

	abstract void Init();
	abstract void Update();
	abstract void Input(KeyPress key);
	abstract void Render(Buffer buf);
}
