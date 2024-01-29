module noro.programs.files;

import std.path;
import std.file;
import noro.app;
import noro.theme;
import noro.program;
import noro.programs.editor;

class FilesProgram : Program {
	string      path;
	DirEntry[]  folder;
	ThemeColour colours;
	size_t      caret;

	this() {
		colours = ThemeColour.Window;
	}
	
	override void Init() {
		path = getcwd();
		LoadFiles();
	}

	void LoadFiles() {
		DirEntry[] newFolder;
		folder = [];
		caret  = 0;

		foreach (entry ; dirEntries(path, SpanMode.shallow)) {
			newFolder ~= entry;
		}

		foreach (entry ; newFolder) {
			if (entry.isDir) {
				folder ~= entry;
			}
		}

		foreach (entry ; newFolder) {
			if (!entry.isDir) {
				folder ~= entry;
			}
		}
	}

	override void Update() {
		
	}

	override void Input(KeyPress key) {
		if (key.mod > 0) return;

		switch (key.key) {
			case Key.Up: {
				if (caret > 0) -- caret;
				break;
			}
			case Key.Down: {
				if (caret < folder.length - 1) ++ caret;
				break;
			}
			case ' ': {
				auto file = folder[caret];

				if (file.isDir) {
					path = file.name;
					LoadFiles();
				}
				else {
					parent.program = new EditorProgram();
					parent.wasInit = false;
					parent.name    = "Editor";

					auto editor = cast(EditorProgram) parent.program;
					editor.OpenFile(file.name);
				}
				break;
			}
			default: break;
		}
	}

	override void OnResize(Vec2!ushort size) {
		
	}

	override void Render(Buffer buf) {
		buf.attr = App.GetTheme().GetColour(colours);
		
		buf.Clear(' ');
		buf.caret = Vec2!ushort(0, 0);

		foreach (ref entry ; folder) {
			if (entry.isDir) {
				buf.SetFGColour(Colour16.Blue); // TODO: customisable
				buf.Printf(" %s/\n", entry.name.baseName());
			}
			else {
				buf.attr = App.GetTheme().GetColour(colours);
				buf.Printf(" %s\n", entry.name.baseName());
			}
		}

		buf.caret = Vec2!ushort(0, cast(ushort) caret);
	}
}
