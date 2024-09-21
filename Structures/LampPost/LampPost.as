// A script by TFlippy & Pirate-Rob

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	
	this.set_bool("isActive", true);
	
	this.addCommandID("sv_toggle");
	this.addCommandID("cl_toggle");
	
	SetState(this, this.get_bool("isActive"));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sv_toggle") && isServer())
	{
		this.set_bool("isActive", !this.get_bool("isActive"));

		CBitStream stream;
		stream.write_bool(this.get_bool("isActive"));
		this.SendCommand(this.getCommandID("cl_toggle"), stream);
	}

	if (cmd == this.getCommandID("cl_toggle") && isClient())
	{
		this.getSprite().PlaySound("LeverToggle.ogg");
		SetState(this, params.read_bool());
	}
}

void SetState(CBlob@ this, bool inState)
{
	this.set_bool("isActive", inState);

	this.SetLight(inState);
	this.SetLightRadius(120.0f);
	this.SetLightColor(SColor(255, 255, 200, 110));

	CSprite@ sprite = this.getSprite();
	sprite.SetAnimation(inState ? "on" : "off");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
	CButton@ buttonEject = caller.CreateGenericButton((this.get_bool("isActive") ? 27 : 23), Vec2f(-0.5f, -4), this, this.getCommandID("sv_toggle"), (this.get_bool("isActive") ? "Turn Off" : "Turn On"));
}