//Contrabass

string[] instrument_names = {"harp"};

void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
	
	this.addCommandID("server_playnote");
	this.addCommandID("client_playnote");
}

void onTick(CBlob@ this)
{
	if (!this.isAttached()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;
	
	const bool isBot = holder.getPlayer() is null;
	
	if (holder.isMyPlayer() || (isBot && isServer()))
	{
		u8 instrument_timer = this.get_u8("instrument_timer");
		instrument_timer = Maths::Max(0, instrument_timer - 1);
		
		u8 instrument_type = this.get_u8("instrument_type");
		if (point.isKeyJustPressed(key_action2))
		{
			instrument_type = instrument_type >= instrument_names.length - 1 ? 0 : instrument_type + 1;
			this.set_u8("instrument_type", instrument_type);
		}
		
		if (instrument_timer == 0 || point.isKeyJustPressed(key_action1))
		{
			const bool pressing_action1 = isBot ? holder.isKeyPressed(key_action1) : point.isKeyPressed(key_action1);
			if (pressing_action1)
			{
				f32 distance = Maths::Sqrt((Maths::Pow(holder.getAimPos().x - holder.getPosition().x, 2)) + (Maths::Pow(holder.getAimPos().y - holder.getPosition().y, 2)));
				if (distance > 37 * 6) distance = 37 * 6;

				const u8 note = Maths::Round(distance / 6);

				const u8 commandID = isServer() ? this.getCommandID("client_playnote") : this.getCommandID("server_playnote");
				sendNoteCMD(this, note, instrument_type, commandID);
				playNote(this, note, instrument_type, 1.0f);
				
				instrument_timer = 15;
			}
		}
		this.set_u8("instrument_timer", instrument_timer);
	}
}

void sendNoteCMD(CBlob@ this, const u8&in note, const u8&in instr_number, const u8&in CMD)
{
	CBitStream stream;
	stream.write_u8(note);
	stream.write_u8(instr_number);
	this.SendCommand(CMD, stream);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("server_playnote"))
	{
		const u8 note = params.read_u8();
		const u8 instr_number = params.read_u8();
		sendNoteCMD(this, note, instr_number, this.getCommandID("client_playnote"));
	}
	else if (cmd == this.getCommandID("client_playnote"))
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (point is null) return;

		CBlob@ playerblob = point.getOccupied();
		if (playerblob is null || playerblob.isMyPlayer()) return;

		const u8 note = params.read_u8();
		const u8 instr_number = params.read_u8();

		Driver@ driver = getDriver();
		Vec2f localpos = driver.getWorldPosFromScreenPos(driver.getScreenCenterPos());
		const f32 distance = (this.getPosition() - localpos).Length();
		const f32 volume = 1.0f - (distance / 430);

		playNote(this, note, instr_number, volume);
	}
}

void playNote(CBlob@ this, const u8&in note, const u8&in instr_number, const f32&in volume)
{
    if (volume < 0.5f) return;

    this.getSprite().PlaySound(instrument_names[instr_number] + note, volume, 1.0f);
}
