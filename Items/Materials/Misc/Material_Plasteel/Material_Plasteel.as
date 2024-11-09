#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Plasteel));
	this.maxQuantity = 50;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
