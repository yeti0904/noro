module noro.uiManager;

import std.algorithm;
import noro.ui.base;
import noro.terminal.input;

class UIManager {
	UIBase[] elements;

	void MoveTop(size_t index) {
		elements[$ - 1].focused = false;

		auto elem  = elements[index];
		elements   = elements.remove(index);
		elements  ~= elem;

		elements[$ - 1].focused = true;
	}

	UIBase Top() {
		return elements[$ - 1];
	}

	void Add(UIBase element) {
		if (elements.length > 0) {
			elements[$ - 1].focused = false;
		}
	
		elements                ~= element;
		elements[$ - 1].focused  = true;
	}

	void Update() {
		foreach (ref elem ; elements) {
			elem.Update();
		}
	}

	void Input(KeyPress key) {
		elements[$ - 1].Input(key);
	}

	void Render(Buffer buf) {
		foreach (ref elem ; elements) {
			elem.Render();
			buf.BlitBuffer(elem.buffer, elem.pos.x, elem.pos.y);
		}
	}

	void SetCaret(Buffer buf) {
		buf.caret    = elements[$ - 1].buffer.caret;
		buf.caret.x += elements[$ - 1].pos.x;
		buf.caret.y += elements[$ - 1].pos.y;
	}
}
