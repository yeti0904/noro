module noro.uiManager;

import std.range;
import std.algorithm;
import noro.ui.base;
import noro.ui.window;
import noro.terminal.input;
import noro.terminal.terminal;

class UIManager {
	UIBase[] elements;

	void MoveTop(size_t index) {
		auto elem  = elements[index];
		elements   = elements.remove(index);
		elements  ~= elem;
	}

	UIBase Top() {
		return elements[$ - 1];
	}

	void Add(UIBase element) {
		elements ~= element;
	}

	void DeleteTop() {
		if (elements.empty) return;
		
		elements = elements[0 .. $ - 1];
	}

	void Update() {
		foreach (ref elem ; elements) {
			elem.Update();
		}
	}

	void Input(KeyPress key) {
		if (elements.empty) return;
		
		Top().Input(key);
	}

	void Render(Buffer buf) {
		foreach (ref elem ; elements) {
			elem.Render(elem is elements[$ - 1]);
			buf.BlitBuffer(elem.buffer, elem.pos.x, elem.pos.y);
		}

		Terminal.SetCursorVisibility(elements.empty? false : Top().CursorVisible());
	}

	void SetCaret(Buffer buf) {
		if (elements.empty) {
			buf.caret = Vec2!ushort(buf.GetSize().x, buf.GetSize().y);
			return;
		}
		
		buf.caret    = Top().buffer.caret;
		buf.caret.x += Top().pos.x;
		buf.caret.y += Top().pos.y;
	}
}
