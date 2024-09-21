
void onInit(CBlob@ this)
{
	if (isServer())
	{
		this.set_u8("decay step", 4);
	}

	this.maxQuantity = 250;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
