// Game Music

#define CLIENT_ONLY

enum GameMusicTag
{
	world_ambient_start,

	world_ambient,
	world_ambient_underground,
	world_ambient_mountain,

	world_ambient_end,

	world_music_start,

	world_intro,
	world_home,
	world_calm,
	world_battle,
	world_battle_2,
	world_outro,
	world_quick_out,

	world_music_end,
};

const string base_blob_name = "fortress";

bool initialized = false;

void onInit(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null) return;

	mixer.ResetMixer();
	initialized = false;
}

void onTick(CBlob@ this)
{
	CMixer@ mixer = getMixer();
	if (mixer is null) return;

	if (s_soundon != 0 && s_musicvolume > 0.0f)
	{
		if (!initialized)
		{
			AddGameMusic(mixer);
			initialized = true;
		}

		GameMusicLogic(mixer);
	}
	else
	{
		mixer.FadeOutAll(0.0f, 2.0f);
	}
}

//sound references with tag
void AddGameMusic(CMixer@ mixer)
{
	mixer.ResetMixer();
	mixer.AddTrack("Sounds/Music/ambient_forest.ogg", world_ambient);
	mixer.AddTrack("Sounds/Music/ambient_mountain.ogg", world_ambient_mountain);
	mixer.AddTrack("Sounds/Music/ambient_cavern.ogg", world_ambient_underground);
	mixer.AddTrack("Sounds/Music/KAGWorldIntroShortA.ogg", world_intro);
	mixer.AddTrack("Sounds/Music/KAGWorld1-1a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-2a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-3a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-4a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-5a.ogg", world_calm);
	mixer.AddTrack("Sounds/Music/KAGWorld1-6a.ogg", world_calm);
	mixer.AddTrack("Sounds/Music/KAGWorld1-7a.ogg", world_calm);
	mixer.AddTrack("Sounds/Music/KAGWorld1-8a.ogg", world_calm);
	mixer.AddTrack("Sounds/Music/KAGWorld1-9a.ogg", world_home);
	mixer.AddTrack("Sounds/Music/KAGWorld1-10a.ogg", world_battle);
	mixer.AddTrack("Sounds/Music/KAGWorld1-11a.ogg", world_battle);
	mixer.AddTrack("Sounds/Music/KAGWorld1-12a.ogg", world_battle);
	mixer.AddTrack("Sounds/Music/KAGWorld1-13+Intro.ogg", world_battle_2);
	mixer.AddTrack("Sounds/Music/KAGWorld1-14.ogg", world_battle_2);
	mixer.AddTrack("Sounds/Music/KAGWorldQuickOut.ogg", world_quick_out);
}

uint timer = 0;

void GameMusicLogic(CMixer@ mixer)
{
	timer++;
	if (!s_gamemusic) return;

	CRules@ rules = getRules();
	CBlob@ blob = getLocalPlayerBlob();
	if (blob is null)
	{
		mixer.FadeOutAll(0.0f, 6.0f);
		return;
	}

	CMap@ map = getMap();
	Vec2f pos = blob.getPosition();

	//calc ambience
	if (timer % 2 == 0)
	{
		const bool isUnderground = map.rayCastSolid(pos, Vec2f(pos.x, pos.y - 60.0f));
		if (isUnderground)
		{
			changeAmbience(mixer, world_ambient_underground, 4.0f, 4.0f);
		}
		else
		{
			//top one fifth is windy
			if (pos.y < map.tilemapheight * map.tilesize * 0.2f)
				changeAmbience(mixer, world_ambient_mountain, 4.0f, 4.0f);
			else
				changeAmbience(mixer, world_ambient, 4.0f, 4.0f);
		}
	}
	
	//every beat, checks situation for appropriate music
	if (rules.isMatchRunning())
	{
		if (playingMusic(mixer) == 0)
		{
			GameMusicTag chosen = world_calm;

			//check blobs around player for various traits
			CBlob@[] bases;
			getBlobsByName(base_blob_name, @bases);
			for (uint i = 0; i < bases.length; i++)
			{
				CBlob@ base = bases[i];
				if (base is null) continue;

				if (base.getDistanceTo(blob) < 400.0f)
				{
					if (base.getTeamNum() >= rules.getTeamsCount()) continue;

					if (base.getTeamNum() != blob.getTeamNum())
						chosen = world_battle;
					else if (chosen != world_battle) //home if we're not within range of battle
						chosen = world_home;
				}
			}

			changeMusic(mixer, chosen);
			timer = 0;
		}
	}
	else //end of game, fade out music
	{
		if (mixer.getPlayingCount() >= 0)
		{
			mixer.FadeOutAll(0.0f, 0.5f);
		}
	}
}

// handle fadeouts / fadeins dynamically
void changeMusic(CMixer@ mixer, int nextTrack, f32 fadeoutTime = 0.0f, f32 fadeinTime = 0.0f)
{
	if (!mixer.isPlaying(nextTrack))
	{
		for (u32 i = world_music_start + 1; i < world_music_end; i++)
			mixer.FadeOut(i, fadeoutTime);
	}

	mixer.FadeInRandom(nextTrack, fadeinTime);
}

u32 playingMusic(CMixer@ mixer)
{
	u32 count = 0;
	for (u32 i = world_music_start + 1; i < world_music_end; i++)
		count += mixer.isPlaying(i) ? 1 : 0;

	return count;
}

// handle fadeouts / fadeins dynamically
void changeAmbience(CMixer@ mixer, int nextTrack, f32 fadeoutTime = 0.0f, f32 fadeinTime = 0.0f)
{
	if (!mixer.isPlaying(nextTrack))
	{
		for (u32 i = world_ambient_start + 1; i < world_ambient_end; i++)
			mixer.FadeOut(i, fadeoutTime);
	}

	mixer.FadeInRandom(nextTrack, fadeinTime);
}
