#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::MachinegunAmmo));
	this.Tag("ammo");
	this.maxQuantity = 60;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
