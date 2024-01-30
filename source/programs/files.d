module noro.programs.files;

import std.file;
import std.path;
import std.range;
import std.format;
import std.algorithm;
import noro.app;
import noro.util;
import noro.program;

class FilesProgram : Program {
	ThemeColour colours;
	DirEntry[]  files;
	size_t      caret;
	size_t      scroll;
	string      folder;
	bool        parentAvailable;
	bool        showHidden = false;
	size_t      maxPathLength;
	size_t      windowLines;

	override void Init() {
		folder = getcwd();
		UpdateFiles();
		colours = ThemeColour.Window;
	}

	void UpdateFiles() {
		files         = [];
		caret         = 0;
		maxPathLength = 0;
		scroll        = 0;

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
		if (key.mod == 0) {
			switch (key.key) {
				case Key.Up: {
					if (caret > 0) {
						-- caret;

						if (scroll > caret) {
							scroll = caret;
						}
					}
					break;
				}
				case Key.Down: {
					if (caret < files.length - 1) {
						++ caret;

						if (caret - scroll >= windowLines) {
							++ scroll;
						}
					}
					break;
				}
				case ' ': {
					if (files.empty) break;
					
					auto file = files[caret];

					if (file.isDir()) {
						folder = buildNormalizedPath(file.name);
						UpdateFiles();
					}
					break;
				}
				case 'd': {
					// i hope god forgives me for this atrocity
					CreateSelectionWindow(
						this, "Delete file",
						format("Delete '%s'?", files[caret].name.baseName()),
						["No", "Yes"], (Program, string option) {
							final switch (option) {
								case "Yes": {
									try {
										remove(files[caret].name);
									}
									catch (FileException e) {
										App.Instance().NewAlert(e.msg, 3);
										return;
									}

									files = files.remove(caret);
									if (caret >= files.length) {
										caret = files.length - 1;
									}
									break;
								}
								case "No": break;
							}
						}
					);
					break;
				}
				default: break;
			}
		}
		else if (key.mod == KeyMod.Ctrl) {
			switch (key.key) {
				case 'o': {
					CreateInputWindow(
						this, "Open folder", "Type a path:",
						(Program program, string path) {
							folder = path;
							UpdateFiles();
						}
					);
					break;
				}
				default: break;
			}
		}
	}

	override void OnResize(Vec2!ushort size) {
		
	}

	override void Render(Buffer buf) {
		windowLines = buf.GetSize().y;

		auto theme = App.GetTheme().GetColour(colours);
		buf.attr   = theme;
		buf.Clear(' ');

		foreach (i, ref file ; files[scroll .. $]) {
			if (i == caret - scroll) {
				buf.attr = theme.Invert();
				buf.HLine(0, cast(ushort) i, buf.GetSize().x, ' ');
			}
			else {
				buf.attr = theme;
			}

			buf.caret = Vec2!ushort(0, cast(ushort) i);

			if ((i == 0) && (scroll == 0) && parentAvailable) {
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

		buf.caret = Vec2!ushort(
			cast(ushort) (buf.GetSize().x - 1), cast(ushort) (caret - scroll)
		);
	}
}
