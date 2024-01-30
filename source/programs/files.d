module noro.programs.files;

import std.file;
import std.path;
import std.algorithm;
import noro.app;
import noro.util;
import noro.program;

class FilesProgram : Program {
	ThemeColour colours;
	DirEntry[]  files;
	size_t      caret;
	string      folder;
	bool        parentAvailable;
	bool        showHidden = false;
	size_t      maxPathLength;

	override void Init() {
		folder = getcwd();
		UpdateFiles();
		colours = ThemeColour.Window;
	}

	void UpdateFiles() {
		files         = [];
		caret         = 0;
		maxPathLength = 0;

		try {
			if (dirName(folder) != folder) {
				auto parent      = DirEntry(dirName(folder));
				files           ~= parent;
				parentAvailable  = true;

				maxPathLength = max(maxPathLength, dirName(folder).baseName().length);
			}
			else {
				parentAvailable = false;
			}
		}
		catch (FileException) {}

		try {
			foreach (DirEntry file ; dirEntries(folder, SpanMode.shallow)) {
				if (file.isDir()) {
					if (!showHidden && file.name.baseName().startsWith(".")) {
						continue;
					}
					
					files ~= file;
					maxPathLength = max(maxPathLength, file.name.baseName().length);
				}
			}

			foreach (DirEntry file ; dirEntries(folder, SpanMode.shallow)) {
				if (!file.isDir()) {
					if (!showHidden && file.name.baseName().startsWith(".")) {
						continue;
					}
					
					files ~= file;
					maxPathLength = max(maxPathLength, file.name.baseName().length);
				}
			}
		}
		catch (FileException e) {
			files = [];
			App.Instance().NewAlert(e.msg, 3);
		}
	}

	override void Update() {
		
	}

	override void Input(KeyPress key) {
		if (key.mod != 0) return;

		switch (key.key) {
			case Key.Up: {
				if (caret > 0) -- caret;
				break;
			}
			case Key.Down: {
				if (caret < files.length - 1) ++ caret;
				break;
			}
			case ' ': {
				auto file = files[caret];

				if (file.isDir()) {
					folder = buildNormalizedPath(file.name);
					UpdateFiles();
				}
				break;
			}
			default: break;
		}
	}

	override void OnResize(Vec2!ushort size) {
		
	}

	override void Render(Buffer buf) {
		auto theme = App.GetTheme().GetColour(colours);
		buf.attr   = theme;
		buf.Clear(' ');

		foreach (i, ref file ; files) {
			if (i == caret) {
				buf.attr = theme.Invert();
				buf.HLine(0, cast(ushort) i, buf.GetSize().x, ' ');
			}
			else {
				buf.attr = theme;
			}

			buf.caret = Vec2!ushort(0, cast(ushort) i);

			if ((i == 0) && parentAvailable) {
				buf.Print("⬑  ");
			}
			else {
				buf.Print("   ");
			}
			buf.Print(file.name.baseName());

			if (file.isDir()) {
				buf.Print("/");
			}

			buf.caret.x = cast(ushort) (maxPathLength + 5);
			buf.Printf("%s", file.size.SizeAsString());
		}

		buf.caret = Vec2!ushort(cast(ushort) (buf.GetSize().x - 1), cast(ushort) caret);
	}
}
