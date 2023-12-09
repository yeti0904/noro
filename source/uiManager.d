module noro.uiManager;

import std.algorithm;
import noro.ui.base;
import noro.terminal.input;

class UIManager {
	UIBase[] elements;
	UIBase   focused;

	void SetFocused(size_t index) {
		focused = elements[index];
	}

	UIBase Focused() {
		return focused;
	}

	void Add(UIBase element) {
		elements ~= element;

		if (elements.length == 1) {
			focused = element;
		}
	}

	void Update() {
		foreach (ref elem ; elements) {
			elem.Update();
		}
	}

	void Input(KeyPress key) {
		focused.Input(key);
	}

	void Render(Buffer buf) {
		foreach (ref elem ; elements) {
			elem.Render(elem is focused);
			buf.BlitBuffer(elem.buffer, elem.pos.x, elem.pos.y);
		}
	}

	void SetCaret(Buffer buf) {
		buf.caret    = focused.buffer.caret;
		buf.caret.x += focused.pos.x;
		buf.caret.y += focused.pos.y;
	}
}
