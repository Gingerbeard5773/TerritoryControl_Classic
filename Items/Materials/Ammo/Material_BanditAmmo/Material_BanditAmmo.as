
void onInit(CBlob@ this)
{
	this.maxQuantity = 40;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}
