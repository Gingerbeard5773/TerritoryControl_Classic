#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::CopperWire));
	this.maxQuantity = 250;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
