// Sleeper.as

void onInit(CSprite@ this)
{
	CSpriteLayer@ zzz = this.addSpriteLayer("zzz", "Quarters.png", 8, 8);
	if (zzz !is null)
	{
		{
			zzz.addAnimation("default", 15, true);
			int[] frames = {96, 97, 98, 98, 99};
			zzz.animation.AddFrames(frames);
		}
		zzz.SetOffset(Vec2f(-3, -7));
		zzz.SetRelativeZ(5);
		zzz.SetLighting(false);
		zzz.SetVisible(false);
	}

	this.getCurrentScript().tickFrequency = 60;
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	CSpriteLayer@ layer = this.getSpriteLayer("zzz");
	if (layer !is null)
	{
		if (blob.hasTag("dead"))
		{
			blob.Untag("sleeper");
			this.getCurrentScript().runFlags |= Script::remove_after_this;
			blob.getCurrentScript().runFlags |= Script::remove_after_this;
		}

		layer.SetVisible(blob.hasTag("sleeper"));
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return this.hasTag("sleeper") && forBlob.getDistanceTo(this) < this.getRadius()*2.5f;
}
