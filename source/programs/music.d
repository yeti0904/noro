module noro.programs.music;

import std.conv;
import std.file;
import std.json;
import std.range;
import std.format;
import noro.app;
import noro.util;
import noro.audio;
import noro.program;

struct Playlist {
	string   name;
	string[] songs;
}

class PlaylistException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

enum MusicViewMode {
	Playlist,
	Queue
}

private class MusicView {
	MusicProgram parent;

	abstract void Input(KeyPress key);
	abstract void Render(Buffer buf);
}

private class PlaylistView : MusicView {
	size_t caret;
	size_t scroll;

	this() {
		
	}

	override void Input(KeyPress key) {
		if (key.mod != 0) return;

		switch (key.key) {
			case Key.Up: {
				if (caret > 0) {
					-- caret;
				}
				break;
			}
			case Key.Down: {
				if (caret < parent.GetPlaylist().songs.length - 1) {
					++ caret;
				}
				break;
			}
			default: break;
		}
	}

	override void Render(Buffer buf) {
		buf.caret = Vec2!ushort(0, 0);

		if (parent.playlists.empty) {
			buf.Printf("No playlists available");
			return;
		}
		
		buf.Printf("Currently viewing: %s", parent.GetPlaylist().name);
		buf.caret = Vec2!ushort(0, 1);

		for (size_t i = 0; i < buf.GetSize().y - 2; ++ i) {
			size_t index = i + scroll;

			if (index >= parent.GetPlaylist().songs.length) {
				break;
			}

			buf.Printf(index == caret? "> " : "  ");
			buf.Printf("%d. %s\n", index, parent.GetPlaylist().songs[index]);
		}
	}
}

private class QueueView : MusicView {
	this() {
		
	}

	override void Input(KeyPress key) {
		
	}

	override void Render(Buffer buf) {
		
	}
}

class MusicProgram : Program {
	ThemeColour   colours;
	Playlist[]    playlists;
	size_t        playlist;
	bool          error;
	string        errorMsg;
	Vec2!ushort   bufSize;
	MusicViewMode view;
	MusicView[]   views;

	this() {
		colours = ThemeColour.Window;

		views                         = new MusicView[](MusicViewMode.max + 1);
		views[MusicViewMode.Playlist] = new PlaylistView();
		views[MusicViewMode.Queue]    = new QueueView();

		foreach (ref view ; views) {
			view.parent = this;
		}

		playlists ~= Playlist(
			"epic playlist",
			[
				"Pindinghall OST - Basil theme",
				"Pindinghall OST - John Paul Smith theme",
				"Pindinghall OST - Hernan Teodoro theme",
				"Pindinghall OST - Downtown Pindinghall theme",
				"Pindinghall OST - baked beans zone",
				"Pindinghall OST - Credits music"
			]
		);
	}

	Playlist* GetPlaylist() {
		return &playlists[playlist];
	}

	Playlist LoadPlaylist(JSONValue value) {
		Playlist ret;

		if (!value.AssertJSON("name", JSONType.string)) {
			throw new PlaylistException("name key not defined or wrong type");
		}

		ret.name = value["name"].str;

		if (!value.AssertJSON("songs", JSONType.array)) {
			throw new PlaylistException("songs key not defined or wrong type");
		}

		foreach (ref song ; value["songs"].array) {
			if (song.type != JSONType.string) {
				throw new PlaylistException("songs element is the wrong type");
			}

			ret.songs ~= song.str;

			if (!exists(song.str)) {
				throw new PlaylistException(format("Song '%s' doesn't exist", song.str));
			}
		}

		return ret;
	}

	override void Init() {
		auto noroPath = App.GetNoroPath();

		MakeFolder(noroPath ~ "/music");
		MakeFile(noroPath ~ "/music/playlists.json", "[]");

		JSONValue playlistsJSON;
		try {
			playlistsJSON = parseJSON(readText(noroPath ~ "/music/playlists.json"));
		}
		catch (JSONException e) {
			error    = true;
			errorMsg = e.msg;
		}
		catch (ConvException e) {
			error    = true;
			errorMsg = e.msg;
		}

		if (playlistsJSON.type != JSONType.array) {
			error    = true;
			errorMsg = "Playlists file doesn't contain an array";
			return;
		}

		foreach (ref playlist ; playlistsJSON.array) {
			try {
				playlists ~= LoadPlaylist(playlist);
			}
			catch (PlaylistException e) {
				error    = true;
				errorMsg = e.msg;
				return;
			}
		}
	}

	override void Update() {
		
	}

	override void Input(KeyPress key) {
		views[view].Input(key);
	}

	override void OnResize(Vec2!ushort size) {
		bufSize = size;
	}
	
	override void Render(Buffer buf) {
		buf.attr = App.GetTheme().GetColour(colours);
		bufSize  = buf.GetSize();

		buf.Clear(' ');
		views[view].Render(buf);
	}
}
