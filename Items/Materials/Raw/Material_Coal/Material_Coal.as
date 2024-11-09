#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(Translate::Coal);
	if (isServer())
	{
		this.set_u8("decay step", 1);
	}

	this.maxQuantity = 50;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
