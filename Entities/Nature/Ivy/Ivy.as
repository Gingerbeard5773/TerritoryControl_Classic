void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	u16 netID = blob.getNetworkID();
	this.animation.frame = (netID % this.animation.getFramesCount());
	this.SetFacingLeft(((netID % 13) % 2) == 0);
	this.SetZ(-5.0f);
}

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	this.Tag("scenary");
}
