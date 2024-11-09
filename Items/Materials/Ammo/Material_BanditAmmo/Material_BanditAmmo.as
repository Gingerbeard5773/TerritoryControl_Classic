#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::BanditAmmo));
	this.Tag("ammo");
	this.maxQuantity = 40;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
