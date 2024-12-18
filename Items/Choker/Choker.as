void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 15 + XORRandom(45);
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	CBlob@[] blobs;
	getMap().getBlobsInBox(this.getPosition() + Vec2f(48, -48), this.getPosition() + Vec2f(-48, 48), @blobs);

	int counter = 0;

	for (int i = 0; i < blobs.length; i++)
	{
		if (blobs[i].getConfig() == "methane") counter++;
	}

	if (counter < 4)
	{
		CBlob@ blob = server_CreateBlob("methane", -1, this.getPosition() + getRandomVelocity(0, XORRandom(16), 360));
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.doTickScripts = true;
}
