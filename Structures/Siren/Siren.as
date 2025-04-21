// A script by TFlippy & Pirate-Rob & Gingerbeard

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("change team on fort capture");

	this.getCurrentScript().tickFrequency = 45;

	this.set_bool("isActive", false);
	this.addCommandID("sv_toggle");
	this.addCommandID("cl_toggle");
}

void onInit(CSprite@ this)
{
	this.SetEmitSound("siren_leveled.ogg");
	this.SetEmitSoundVolume(0.0f);
	this.SetEmitSoundSpeed(1.0f);
	this.SetEmitSoundPaused(true);
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	CBlob@[] blobs;
	getBlobsByTag("aerial", @blobs);

	Vec2f pos = this.getPosition();

	for (int i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if ((blob.getPosition() - pos).Length() < 750.0f && blob.getTeamNum() != this.getTeamNum())
		{
			if (this.get_bool("isActive")) return;

			this.set_bool("isActive", true);

			CBitStream stream;
			stream.write_bool(true);
			this.SendCommand(this.getCommandID("cl_toggle"), stream);

			return;
		}
	}

	if (this.get_bool("isActive"))
	{
		this.set_bool("isActive", false);

		CBitStream stream;
		stream.write_bool(false);
		this.SendCommand(this.getCommandID("cl_toggle"), stream);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sv_toggle") && isServer())
	{
		const bool active = params.read_bool();

		this.set_bool("isActive", active);

		CBitStream stream;
		stream.write_bool(active);
		this.SendCommand(this.getCommandID("cl_toggle"), stream);
	}
	else if (cmd == this.getCommandID("cl_toggle") && isClient())
	{
		const bool active = params.read_bool();
		this.set_bool("isActive", active);

		CSprite@ sprite = this.getSprite();
		sprite.PlaySound("LeverToggle.ogg");
		sprite.SetEmitSound("siren_leveled.ogg");
		sprite.SetEmitSoundPaused(false);
		sprite.SetAnimation(active ? "on" : "off");
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null || !isClient()) return;

	f32 current_volume = this.getEmitSoundVolume();
	const bool active = blob.get_bool("isActive");
	const f32 target_volume = active ? 2.0f : 0.0f;

	if (Maths::Abs(current_volume - target_volume) > 0.01f)
	{
		if (current_volume < target_volume)
			current_volume = Maths::Min(current_volume + 0.05f, target_volume);
		else
			current_volume = Maths::Max(current_volume - 0.05f, target_volume);

		this.SetEmitSoundVolume(current_volume);
	}

	if (current_volume <= 0.01f && !active)
	{
		this.SetEmitSoundPaused(true);
	}
}


// void GetButtonsFor(CBlob@ this, CBlob@ caller)
// {
	// if (!this.isOverlapping(caller)) return;
	
	// CBitStream params;
	// params.write_bool(!this.get_bool("isActive"));
	
	// CButton@ buttonEject = caller.CreateGenericButton(11, Vec2f(0, -8), this, this.getCommandID("sv_toggle"), (this.get_bool("isActive") ? "Turn Off" : "Turn On"), params);
// }