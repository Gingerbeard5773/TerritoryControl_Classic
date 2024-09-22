// Made by TFlippy, voiced by Rob
#define CLIENT_ONLY

const string[] wordreplace =
{
	"destroy", "vo_destroy.ogg",
	"attack", "vo_attack.ogg",
	"ladder", "vo_ladder.ogg",

	"chicken", "vo_chicken.ogg",
	"neutral", "vo_neutral.ogg",
	"bandit", "vo_bandit.ogg",
	"builder", "vo_builder.ogg",
	"knight", "vo_knight.ogg",
	"archer", "vo_archer.ogg",
	
	"strong", "vo_strong.ogg",
	"build", "vo_build.ogg",
	
	"lalala", "vo_lalala_2.ogg",
	"la la la", "vo_lalala.ogg",
	
	"idiot", "vo_idiot.ogg",
	"jerk", "vo_jerk.ogg",
	"bad", "vo_bad.ogg",
	"water", "vo_water.ogg",
	"join", "vo_join.ogg",
	"kill", "vo_kill.ogg",
	"need", "vo_need.ogg",
	"give", "vo_give.ogg",
	"help", "vo_help.ogg",
	"look", "vo_look.ogg",
	"fire", "vo_fire.ogg",
	"lag", "vo_lag.ogg",
	"die", "vo_die.ogg",
	"rip", "vo_rip.ogg",
	"gun", "vo_gun.ogg",
	"run", "vo_run.ogg",
	"why", "vo_why.ogg",
	"yes", "vo_yes.ogg",
	"ye", "vo_yes.ogg",
	"no", "vo_no.ogg",
	
	"haha", "vo_haha.ogg",
	"lol", "vo_haha.ogg",
	
	"hi", "vo_hi.ogg",
	"hello", "vo_hello.ogg",
	
	"okay", "vo_okay.ogg",
	"ok", "vo_okay.ogg",
	
	"what", "vo_what.ogg",
	"wat", "vo_what.ogg",
	"wut", "vo_what.ogg",
	
	"please", "vo_please.ogg",
	"pls", "vo_please.ogg",
	"plz", "vo_please.ogg"
};

// shared class VoiceSample
// {
	// string filename;
	// f32 delay;
// };

// shared class VoiceSequence
// {
	// VoiceSample[] samples;
	// u32 position;
// };

bool isupper(u8 c)
{
	return (c >= 0x41 && c <= 0x5A);
}

u8 tolower(u8 c)
{
	if (isupper(c))
		c += 0x20;
	return c;
}

string tolower(string s)
{
	int len = s.size();
	for (int i = 0; i < len; i++)
		s[i] = tolower(s[i]);
	return s;
}

// void onInit(CRules@ this)
// {
	// Reset(this);
// }

// void onRestart(CRules@ this)
// {
	// Reset(this);
// }

// void Reset(CRules@ this)
// {
	// VoiceSequence[]@ sequences;
	// this.set("VoiceSequences", sequences);
// }

// void onTick(CRules@ this)
// {
	// VoiceSequence[]@ sequences;
	// this.get("VoiceSequences", @sequences);

	// if (sequences !is null)
	// {
	
		// for (int i = 0; i < sequences.length; i++)
		// {
			// print("" + i);
		// }
	// }
// }

void ProcessText(const string &in textIn, CPlayer@ ply)
{
	const string comparetext = tolower(textIn);
	for (uint i = 0; i < wordreplace.length - 1; i += 2)
	{
		const int pos = comparetext.find(wordreplace[i]);
		if (pos != -1)
		{
			if (ply !is null)
			{
				CBlob@ blob = ply.getBlob();
				if (blob !is null)
				{
					f32 pitch = blob.getSexNum() == 0 ? 0.9f : 1.5f;
					if (blob.exists("voice pitch")) pitch = blob.get_f32("voice pitch");
					
					blob.getSprite().PlaySound(wordreplace[i + 1], 2.00f, pitch);
				}
			}
		
			break;
		}
	}

	return;
}

bool onClientProcessChat(CRules@ this, const string &in textIn, string &out textOut, CPlayer@ player)
{
	ProcessText(textIn, player);
	return true;
}
