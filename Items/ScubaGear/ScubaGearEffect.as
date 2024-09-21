void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30;
	this.set_u8("breath timer", 1);
	this.set_bool("inhale", false);
}

void onTick(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30; //has to be in ontick because of engine issue :/
	if (isClient())
	{
		if (this.get_u8("breath timer") == 2)
		{
			const bool inhale = this.get_bool("inhale");
			this.getSprite().PlaySound("Sounds/gasp.ogg", 0.75f, inhale ? 0.8f : 0.75f);
			this.set_bool("inhale", !inhale);
		}
		this.set_u8("breath timer", (this.get_u8("breath timer") % 2) + 1);
	}
}
