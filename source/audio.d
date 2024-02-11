module noro.audio;

import std.string;

public import bindbc.sdl;

class AudioException : Exception {
	this(string msg, string file = __FILE__, size_t line = __LINE__) {
		super(msg, file, line);
	}
}

class Audio {
	Mix_Music* music;

	this() {
		
	}

	static Audio Instance() {
		static Audio instance;

		if (!instance) {
			instance = new Audio();
		}

		return instance;
	}

	void Error(Char, A...)(in Char[] fmt, A args) {
		throw new AudioException(format(fmt, args));
	}

	void Init() {
		if (loadSDL() != sdlSupport) {
			throw new AudioException("Failed to load SDL");
		}
		if (loadSDLMixer() < SDLMixerSupport.v2_0_0) {
			throw new AudioException("Failed to load SDL Mixer");
		}

		if (SDL_Init(SDL_INIT_AUDIO) < 0) {
			Error("Failed to init SDL: %s", SDL_GetError().fromStringz());
		}

		if (Mix_Init(0xFFFFFFFF) == 0) {
			Error("Failed to init SDL_mixer: %s", Mix_GetError().fromStringz());
		}

		if (
			Mix_OpenAudio(
				MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, MIX_DEFAULT_CHANNELS, 4096
			) < 0
		) {
			Error("Failed to open audio: %s", Mix_GetError().fromStringz());
		}

		Mix_VolumeMusic(100);
		Mix_SetMusicCMD(SDL_getenv("MUSIC_CMD"));
	}

	void Free() {
		if (music !is null) {
			Mix_FreeMusic(music);
		}

		Mix_Quit();
		SDL_Quit();
	}

	void Play(string path) {
		if (music !is null) {
			Mix_FreeMusic(music);
		}

		music = Mix_LoadMUS(path.toStringz());
		if (music is null) {
			Error("Failed to load audio: %s", Mix_GetError().fromStringz());
		}

		if (Mix_PlayMusic(music, 0) != 0) {
			Error("Failed to play audio '%s': %s", path, Mix_GetError());
		}
	}
}
