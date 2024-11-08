void onInit(CBlob@ this)
{
	this.Tag("furniture");
	this.Tag("heavy weight");
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return true;
}
