#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(Translate::Meat);
	if (isServer())
	{
		this.set_u8("decay step", 14);
	}

	this.maxQuantity = 250;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
