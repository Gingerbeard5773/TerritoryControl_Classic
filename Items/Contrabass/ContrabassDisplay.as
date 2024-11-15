
string[] note_names = {"B","C","C#","D","D#","E","F","F#","G","G#","A","A#"};

string[] layout_names = {"piano", "bayan", "guitar", "wicki", "midi"};

string[] instr_names = {"harp", "banjo", "guitar"};

const SColor firstcolor(255, 255, 255, 0);
const SColor secondcolor(255, 255, 0, 0);
const SColor thirdcolor(255, 255, 0, 255);
const SColor fourthcolor(255, 0, 255, 255);
const SColor fifthcolor(255, 0, 255, 0);

//todo: translation

void displayNoteName(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	pos.y -= 5;
	Vec2f screenpos = getDriver().getScreenPosFromWorldPos(pos);
	const s8 note = this.get_u8("note");
	const s8 oct_num = (Maths::Floor((note-1)/12)+1);

	GUI::DrawText(note_names[(note%12)]+oct_num, screenpos, SColor(255, 255, 0, 200));
	this.set_u8("note_display_timer", this.get_u8("note_display_timer") - 1);
}

void displayLayoutName(CBlob@ this)
{
	Vec2f pos = this.getPosition();
	pos.y += 5;
	Vec2f screenpos = getDriver().getScreenPosFromWorldPos(pos);
	GUI::DrawText(layout_names[this.get_u8("layout_number")], screenpos, this.hasTag("music_mode") ? fifthcolor : secondcolor);
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (blob.get_u8("note_display_timer") > 0)
		displayNoteName(blob);

	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	if (holder !is null && holder.isMyPlayer())
	{
		displayLayoutName(blob);
		displayHelp(blob, holder);
	}
}

u8 pages = 0;
u8 pages_timer = 0;
u8 timer_limit = 15;

void displayHelp(CBlob@ this, CBlob@ holder)
{
	CControls@ controls = holder.getControls();
	if (controls is null) return;

	u8 prev_pages = pages;
	Vec2f scr = getDriver().getScreenDimensions();
	Vec2f helppos = scr/2;
	helppos.y = scr.y * 0.22f;

	if (pages == 0)
	{
		GUI::DrawTextCentered("Press F7 for help.", helppos, thirdcolor);
		GUI::DrawTextCentered("Press F8 for GUI.", helppos + Vec2f(0, 10), thirdcolor);
		if (pages_timer == 0)
		{
			if (controls.isKeyPressed(KEY_F7)) pages = 2;
			else if (controls.isKeyPressed(KEY_F8)) pages = 1;
			if (pages != prev_pages) pages_timer = timer_limit;
		}
	}
	else if(pages == 1)
	{
		bool music_mode = this.hasTag("music_mode");
		u8 layout_number = this.get_u8("layout_number");
		u8 instr_number = this.get_u8("instr_number");
		s8 octave_mod = this.get_s8("octave_mod");
		s8 key_shift = this.get_s8("key_shift");
		s8 note = this.get_u8("note");;
		s8 oct_num = (Maths::Floor((note-1)/12)+1);

		GUI::DrawTextCentered("Press F7 for help.", helppos, thirdcolor);
		GUI::DrawTextCentered("Press F8 to close GUI.", helppos + Vec2f(0, 10), firstcolor);

		GUI::DrawText("Layout="+layout_names[layout_number]+", Instr="+instr_names[instr_number], Vec2f(0, scr.y*6/8) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
		GUI::DrawText("Note = "+note_names[(note%12)]+oct_num+"  "+note, Vec2f(0, scr.y*6/8+10) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
		bool isGuitar = (layout_number == 2);
		GUI::DrawText("octave shift = "+octave_mod, Vec2f(0, scr.y*6/8+20) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);
		GUI::DrawText((isGuitar?"string":"key")+" shift = "+key_shift, Vec2f(0, scr.y*6/8+30) , Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thirdcolor, true, true);

		if (isGuitar)
		{
			for (s8 i = 7; i > 0; i--)
			{
				const bool withinRange = ((key_shift < i) && (i <= (key_shift + 4)));
				const s8 number = (note + 1 - 5 * i);

				SColor thiscolor;
				if (withinRange) thiscolor = firstcolor;
				else thiscolor = secondcolor;
				GUI::DrawText(""+i+":"+number, Vec2f(0, scr.y*6/8+40+(7-i)*10), Vec2f(scr.x/2 + scr.x/4 , scr.y/12), thiscolor, true, true);
			}
		}

		if (pages_timer == 0)
		{
			if (controls.isKeyPressed(KEY_F7)) pages = 2;
			else if (controls.isKeyPressed(KEY_F8)) pages = 0;
			if (pages != prev_pages) pages_timer = timer_limit;
		}
	}
	else if (pages == 2)
	{
		GUI::DrawTextCentered("Press F7 to close help.", helppos, firstcolor);
		GUI::DrawTextCentered("Press F8 for GUI.", helppos + Vec2f(0, 10), thirdcolor);

		GUI::DrawText("-to start using the instrument press Space (press Space again to disable it).",Vec2f(0, scr.y/20+scr.y/7) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
		GUI::DrawText("-press keyboard letters/characters/symbols to start playing music.",Vec2f(0,  scr.y/4) , Vec2f(scr.x/2 + scr.x/4 , scr.y/10), secondcolor, true, true);
		GUI::DrawText("-press left Ctrl to cycle through layouts.",Vec2f(0, scr.y/15+scr.y/4) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
		GUI::DrawText("-press right Ctrl to cycle through instruments.",Vec2f(0, scr.y/15+scr.y/4+10) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);

		GUI::DrawText("-press left and right Alt to change octave shift.",Vec2f(0, scr.y/15+scr.y/4+20) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
		GUI::DrawText("-press F9 and F10 to change key shift on piano or string shift on guitar.",Vec2f(0, scr.y/15+scr.y/4+30) , Vec2f(scr.x/2 + scr.x/4 , scr.y/7), secondcolor, true, true);
		if (pages_timer == 0)
		{
			if (controls.isKeyPressed(KEY_F7)) pages = 0;
			else if (controls.isKeyPressed(KEY_F8)) pages = 1;
			if (pages != prev_pages) pages_timer = timer_limit;
		}
	}
	if (pages_timer > 0)
		pages_timer--;
}
