#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::HighCalAmmo));
	this.Tag("ammo");
	this.maxQuantity = 10;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
