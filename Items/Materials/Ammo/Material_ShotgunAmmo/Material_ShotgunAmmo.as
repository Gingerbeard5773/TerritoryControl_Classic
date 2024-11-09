#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::ShotgunAmmo));
	this.Tag("ammo");
	this.maxQuantity = 12;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
