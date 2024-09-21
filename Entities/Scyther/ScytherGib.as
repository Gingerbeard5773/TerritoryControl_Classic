void onInit(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	const u8 frame = blob.exists("frame") ? blob.get_u8("frame") : XORRandom(4);
	this.SetFrameIndex(frame);
}
