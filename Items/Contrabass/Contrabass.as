// Original by Domenje & Jonipro from https://forum.thd.vg/threads/compressed-musical-bucket.27529/

#include "TC_Translation.as";

namespace Layout
{
	enum LayoutNumbers
	{
		piano = 0,
		bayan,
		guitar,
		wicki,
		midi
	}
}

namespace Instr
{
	enum InstrNumbers
	{
		harp = 0,
		banjo,
		guitar
	}
}

const string[] instrument_names = {"harp", "banjo", "guitar"};
const bool V = true;
const bool X = false;
const bool[][] soundfiles = { 
{V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V},//37 files, starting with 0
{V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V},
{V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V,V},
};

f32 half_step_F = 1.059460646483;

const u8[][] layout_keys = {
{KEY_KEY_1,KEY_KEY_2,KEY_KEY_3,KEY_KEY_4,KEY_KEY_5,KEY_KEY_6,KEY_KEY_7,KEY_KEY_8,KEY_KEY_9,KEY_KEY_0,189,187,220,
KEY_KEY_Q,KEY_KEY_W,KEY_KEY_E,KEY_KEY_R,KEY_KEY_T,KEY_KEY_Y,KEY_KEY_U,KEY_KEY_I,KEY_KEY_O,KEY_KEY_P,219,221,
KEY_KEY_A,KEY_KEY_S,KEY_KEY_D,KEY_KEY_F,KEY_KEY_G,KEY_KEY_H,KEY_KEY_J,KEY_KEY_K,KEY_KEY_L,186,222,
KEY_KEY_Z,KEY_KEY_X,KEY_KEY_C,KEY_KEY_V,KEY_KEY_B,KEY_KEY_N,KEY_KEY_M,188,190,191},

{0,0,0,0,0,0,0,0,0,0,0,0,8,
 0,0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0,0,
 0,0,0,0,0,0,0,0,0,0},
};

const u8[][] control_keys = {
{KEY_SPACE,162,163,164,165,KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11},
{0,17,16,37,39,0,0,0,0},
};

const u8[] keys_piano_white = 
{14,15,16,17,18,19,20,21,22,23,24,25,
 37,38,39,40,41,42,43,44,45,46};

const u8[][] keys_piano_black = {
{1,2,3,4,5,6,7,8,9,10,11,12,13,
 27,28,29,30,31,32,33,34,35,36},
 {0,0,0,0,0,0,0,0,0,0,0,0,26,
 0,0,0,0,0,0,0,0,0,0},
};

const u8[] white_keys_pitch = {1,3,5,6,8,10,12};
const u8[] black_keys_pitch = {0,2,4,0,7,9,11};
const u8[] keys_bayan = {1,14,26, 2,15,27, 3,16,28, 4,17,29, 5,18,30, 6,19,31, 7,20,32, 8,21,33, 9,22,34, 10,23,35, 11,24,36, 12,25};
const u8[] keys_midi = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46};

const u8[][] key_notes_wicki = 
{{KEY_KEY_2,0,KEY_KEY_3,0,KEY_KEY_4,KEY_KEY_Q,
  KEY_KEY_5,KEY_KEY_W,KEY_KEY_6,KEY_KEY_E,KEY_KEY_7,KEY_KEY_R,KEY_KEY_8,KEY_KEY_T,KEY_KEY_9,KEY_KEY_Y,KEY_KEY_0,KEY_KEY_U,
  KEY_KEY_G,KEY_KEY_I,KEY_KEY_H,KEY_KEY_O,KEY_KEY_J,KEY_KEY_P,KEY_KEY_K,KEY_KEY_B,KEY_KEY_L,KEY_KEY_N,186,KEY_KEY_M,
  0,188,0,190,0,191},
 {0,0,0,0,0,0,
  0,0,0,0,0,0,KEY_KEY_S,0,KEY_KEY_D,0,KEY_KEY_F,KEY_KEY_Z,
  0,KEY_KEY_X,0,KEY_KEY_C,0,KEY_KEY_V,0,0,0,0,0,0,
  0,0,0,0,0,0},
};

const u8[][] key_notes_guitar =    //Z = E1  ,A = A1, Q = D2, 1 = G2
{{ KEY_KEY_Z,KEY_KEY_X,KEY_KEY_C,KEY_KEY_V,KEY_KEY_B,KEY_KEY_N,KEY_KEY_M,188,
   190,191,KEY_KEY_H,KEY_KEY_J,KEY_KEY_K,KEY_KEY_L,186,222,KEY_KEY_U,KEY_KEY_I,KEY_KEY_O,KEY_KEY_P,
   219,221,KEY_KEY_8,KEY_KEY_9,KEY_KEY_0,189,187,220 },   //  / = C#1, K = E2  
 { 0,0,0,0,0,KEY_KEY_A,KEY_KEY_S,KEY_KEY_D,
   KEY_KEY_F,KEY_KEY_G,KEY_KEY_Q,KEY_KEY_W,KEY_KEY_E,KEY_KEY_R,KEY_KEY_T,KEY_KEY_Y,KEY_KEY_2,KEY_KEY_3,KEY_KEY_4,KEY_KEY_5,
   KEY_KEY_6,KEY_KEY_7,0,0,0,0,0,8},
 { 0,0,0,0,0,0,0,0,
   0,0,0,0,0,0,0,KEY_KEY_1,0,0,0,0,
   0,0,0,0,0,0,0,0,0},
};

f32[] pitch_table;

bool checkControlKey(CControls@ controls, const u8&in ckey_num)
{
	for (u8 i = 0; i < control_keys.size()-1 && control_keys[i][ckey_num] != 0; i++)
		if (controls.isKeyJustPressed(control_keys[i][ckey_num]))
			return true;

	return false;
}
void onInit(CBlob@ this)
{
	f32 current_pitch = 1;
	for (u8 i = 0; i < 30; i++)
	{
		current_pitch *= half_step_F;
		pitch_table.push_back(current_pitch);
	}

	this.setInventoryName(name(Translate::Contrabass));

	this.set_bool("music_mode", false);
	this.set_u8("layout_number", 0);
	this.set_u8("instr_number", 0);
	this.set_s8("octave_mod", 0);
	this.set_s8("key_shift", 0);
	this.set_u8("note", 0);
	this.set_u8("note_display_timer", 0);

	this.addCommandID("server_note");
	this.addCommandID("client_note");

	this.getCurrentScript().runFlags |= Script::tick_attached;
}

void sendNote(CBlob@ this, const u8&in note, const u8&in instr_number)
{
	if (isServer()) return;

	CBitStream stream;
	stream.write_u8(note);
	stream.write_u8(instr_number);
	this.SendCommand(this.getCommandID("server_note"), stream);
}

void onTick(CBlob@ this)
{
	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (point is null) return;

	CBlob@ holder = point.getOccupied();
	if (holder is null) return;

	bool music_mode = this.hasTag("music_mode");
	if (music_mode)
		point.SetKeysToTake(0xFFFF);
	else
		point.SetKeysToTake(key_action1 | key_action2 | key_action3);

	if (!holder.isMyPlayer()) return;

	CControls@ controls = holder.getControls();
	if (controls is null) return;

	if (controls.isKeyJustPressed(KEY_SPACE))
	{
		music_mode = !music_mode;
		this.set_bool("music_mode", music_mode);
		this.Sync("music_mode", true);
	}

	u8 layout_number = this.get_u8("layout_number");
	u8 instr_number = this.get_u8("instr_number");
	s8 octave_mod = this.get_s8("octave_mod");
	s8 key_shift = this.get_s8("key_shift");

	if (checkControlKey(controls, 2)) //163 - right CTRL
	{
		instr_number = (instr_number + 1) % (instrument_names.size());
		this.set_u8("instr_number", instr_number);
	}

	if (checkControlKey(controls, 1)) //162 - left CTRL
	{
		layout_number = (layout_number + 1) % (Layout::midi + 1);
		this.set_u8("layout_number", layout_number);
		this.set_s8("octave_mod", 0);
		this.set_s8("key_shift", 0);
		octave_mod = 0;
		key_shift = 0;
	}

	if (!music_mode) return;

	if (layout_number == Layout::piano)
	{
		if (checkControlKey(controls, 3)) //164 - left ALT
			octave_mod = Maths::Max(octave_mod - 1, -1);

		if (checkControlKey(controls, 4)) //165 - right ALT
			octave_mod = Maths::Min(octave_mod + 1, 2);

		this.set_s8("octave_mod", octave_mod);

		if (checkControlKey(controls, 7)) //120 - F9
			key_shift = Maths::Max(key_shift - 1, -13);

		if (checkControlKey(controls, 8)) //121 - F10
			key_shift = Maths::Min(key_shift + 1, 13);

		this.set_s8("key_shift", key_shift);

		for(s8 i = 0; i < keys_piano_white.size(); i++)
		{
			u8 j = 0;
			for(;j<layout_keys.size()-1 && (!controls.isKeyJustPressed(layout_keys[j][keys_piano_white[i]-1]) || layout_keys[j][keys_piano_white[i]-1] == 0);j++){}
			if(j == layout_keys.size() - 1) continue;

			s8 shifted_key = i + key_shift;
			s8 supposed_note = ((shifted_key/7 - (shifted_key>=0?0:1)) +octave_mod)*12 + white_keys_pitch[shifted_key>=0?shifted_key%7:7+(shifted_key%7)];

			if (supposed_note < 0) continue;
			sendNote(this, supposed_note, instr_number);
			playNote(this, instr_number, supposed_note, 1.0f);
		}

		for(s8 k = 0; k < keys_piano_black.size() - 1; k++)
		{
			for(s8 i = 0; i < keys_piano_black[k].size(); i++)
			{
				if (keys_piano_black[k][i] == 0) continue;

				u8 j = 0;
				for(;j<layout_keys.size()-1 && (!controls.isKeyJustPressed(layout_keys[j][keys_piano_black[k][i]-1]) || layout_keys[j][keys_piano_black[k][i]-1] == 0);j++){}
				if(j == layout_keys.size() - 1) continue;

				s8 shifted_key = i + key_shift;
				u8 key_num = shifted_key>=0?shifted_key%7:7+(shifted_key%7);

				if(black_keys_pitch[key_num] == 0) continue;

				s8 supposed_note = ((shifted_key/7 - (shifted_key>=0?0:1)) +octave_mod)*12 + black_keys_pitch[key_num];
				if(supposed_note < 0) continue;

				sendNote(this, supposed_note, instr_number);
				playNote(this, instr_number, supposed_note, 1.0f);
			}
		}
	}
	else if (layout_number == Layout::bayan)
	{
		if (checkControlKey(controls, 3)) //164 - left ALT
			octave_mod = Maths::Max(octave_mod - 1, -1);

		if (checkControlKey(controls, 4)) //165 - right ALT
			octave_mod = Maths::Min(octave_mod + 1, 2);

		this.set_s8("octave_mod", octave_mod);

		for(u8 i = 0; i < keys_bayan.size(); i++)
		{
			u8 j = 0;
			for(;j<layout_keys.size()-1 && (!controls.isKeyJustPressed(layout_keys[j][keys_bayan[i]-1]) || layout_keys[j][keys_bayan[i]-1] == 0);j++){}
			if(j == layout_keys.size() - 1) continue;
			s8 supposed_note = i+1+octave_mod*12;
			if(supposed_note < 0) continue;
			sendNote(this, supposed_note, instr_number);
			playNote(this, instr_number, supposed_note, 1.0f);
		}
	}
	else if(layout_number == Layout::guitar)
	{
		if (checkControlKey(controls, 3)) //164 - left ALT
			octave_mod = Maths::Max(octave_mod - 1, -2);

		if (checkControlKey(controls, 4)) //165 - right ALT
			octave_mod = Maths::Min(octave_mod + 1, 2);

		this.set_s8("octave_mod", octave_mod);

		if (checkControlKey(controls, 7)) //120 - F9
			key_shift = Maths::Max(key_shift - 1, 0);

		if (checkControlKey(controls, 8)) //121 - F10
			key_shift = Maths::Min(key_shift + 1, 3);

		this.set_s8("key_shift", key_shift);

		for(u8 i = 0; i < key_notes_guitar[0].size(); i++)
		{
			for(u8 j = 0; j < 3 && key_notes_guitar[j][i] != 0; j++)
			{
				if (controls.isKeyJustPressed(key_notes_guitar[j][i]))
				{
					s8 supposed_note = i+5+(octave_mod*12)+key_shift*5;
					if(supposed_note < 0) continue;
					sendNote(this, supposed_note, instr_number);
					playNote(this, instr_number, supposed_note, 1.0f);
					break;
				}
			}
		}
	}
	else if (layout_number == Layout::wicki)
	{
		if (checkControlKey(controls, 3)) //164 - left ALT
			octave_mod = Maths::Max(octave_mod - 1, -1);

		if (checkControlKey(controls, 4)) //165 - right ALT
			octave_mod = Maths::Min(octave_mod + 1, 2);

		this.set_s8("octave_mod", octave_mod);

		for(u8 i = 0; i < key_notes_wicki[0].size(); i++)
		{
			for(u8 j = 0; j < 2 && key_notes_wicki[j][i] != 0; j++)
			{
				if (controls.isKeyJustPressed(key_notes_wicki[j][i]))
				{
					s8 supposed_note = i + (octave_mod * 12) - 5;
					if (0 <= supposed_note)
					{
						sendNote(this, supposed_note, instr_number);
						playNote(this, instr_number, supposed_note, 1.0f);
						break;
					}
				}
			}
		}
	}
	else if (layout_number == Layout::midi)
	{
		if (controls.isKeyJustPressed(164)) //164 - left ALT
			octave_mod = Maths::Max(octave_mod - 1, 0);

		if (controls.isKeyJustPressed(165)) //165 - right ALT
			octave_mod = Maths::Min(octave_mod + 1, 1);

		this.set_s8("octave_mod", octave_mod);

		for (u8 i = 0; i < keys_midi.size(); i++)
		{
			u8 j = 0;
			for (;j<layout_keys.size()-1 && (!controls.isKeyJustPressed(layout_keys[j][keys_midi[i]-1]) || layout_keys[j][keys_midi[i]-1] == 0);j++){}
			if (j == layout_keys.size() - 1) continue;
			const s8 supposed_note = i+1+octave_mod*12;
			if (supposed_note < 0) continue;
			sendNote(this, supposed_note, instr_number);
			playNote(this, instr_number, supposed_note, 1.0f);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server_note") && isServer())
	{
		u8 note;
		u8 instr_number;
		if (!params.saferead_u8(note)) return;
		if (!params.saferead_u8(instr_number)) return;

		CBitStream stream;
		stream.write_u8(note);
		stream.write_u8(instr_number);
		this.SendCommand(this.getCommandID("client_note"), stream);
	}
	else if (cmd == this.getCommandID("client_note") && isClient())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) return;

		CBlob@ holder = point.getOccupied();
		if (holder is null || holder.isMyPlayer()) return;

		u8 note;
		u8 instr_number;
		if (!params.saferead_u8(note)) return;
		if (!params.saferead_u8(instr_number)) return;

		playNote(this, instr_number, note, 1.0f);
	}
}

void playNote(CBlob@ this, const u8&in instr_number, const u8&in note, const f32&in volume)
{
	this.set_u8("note", note);
	this.set_u8("note_display_timer", 40);

	f32 pitch = 1.0f;
	u8 supposed_note = note;
	if (supposed_note >= soundfiles[instr_number].size() || !soundfiles[instr_number][supposed_note])
	{
		u8 file_num = Maths::Min(supposed_note, soundfiles[instr_number].size() - 1);
		while (!soundfiles[instr_number][file_num])
		{
			file_num--;
		}
		const u8 diff = supposed_note - file_num;
		if (diff < 30)
			pitch = pitch_table[diff - 1];
		supposed_note = file_num;
	}
	this.getSprite().PlaySound(instrument_names[instr_number]+(supposed_note), volume, pitch);
}
