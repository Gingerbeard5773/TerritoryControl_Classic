#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(Translate::IronOre);
	if (isServer())
	{
		this.set_u8("decay step", 3);
	}

	this.maxQuantity = 250;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
