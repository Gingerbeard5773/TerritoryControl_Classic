
void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 100 + XORRandom(50);
	this.getSprite().SetZ(-10.0f);

	this.getShape().SetStatic(true);
	this.Tag("builder always hit");

	this.set_u8("gas_left", 30 + XORRandom(30));
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	CBlob@[] blobs;
	getMap().getBlobsInBox(this.getPosition() + Vec2f(48, -48), this.getPosition() + Vec2f(-48, 48), @blobs);

	int counter = 0;

	for (u16 i = 0; i < blobs.length; i++) if (blobs[i].getConfig() == "methane") counter++;

	if (counter < 8)
	{
		CBlob@ blob = server_CreateBlob("methane", -1, this.getPosition() + getRandomVelocity(0, XORRandom(16), 360));
		this.set_u8("gas_left", this.get_u8("gas_left") - 1);
		
		if (this.get_u8("gas_left") <= 0)
		{
			this.server_Die();
		}
	}
}
