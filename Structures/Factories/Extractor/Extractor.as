
void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("gear");
	CSpriteLayer@ gear = this.addSpriteLayer("gear", "Extractor.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
	if (gear !is null)
	{
		Animation@ anim = gear.addAnimation("default", 0, false);
		anim.AddFrame(2);
		gear.SetOffset(Vec2f(0.0f, -6.0f));
		gear.SetAnimation("default");
		gear.SetRelativeZ(-60);
	}
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ gear = this.getSpriteLayer("gear");
	if (gear !is null)
	{
		gear.RotateBy(5, Vec2f(0.5f, -0.5f));
	}
}

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	this.Tag("ignore extractor");
}

void onTick(CBlob@ this)
{
	const bool hasFilter = this.getInventory().getItemsCount() > 0;
	CBlob@[] blobsInRadius;
	getMap().getBlobsInRadius(this.getPosition(), 32.0f, @blobsInRadius);

	for (uint i = 0; i < blobsInRadius.length; i++)
	{
		CBlob@ b = blobsInRadius[i];
		CInventory@ inv = b.getInventory();
		if (inv is null || b.hasTag("player")) continue;

		if (b.getTeamNum() != this.getTeamNum() || b.hasTag("ignore extractor")) continue;

		const u16 items_count = inv.getItemsCount();
		for (uint q = 0; q < items_count; q++)
		{
			CBlob@ item = inv.getItem(q);
			if (!hasFilter || this.hasBlob(item.getName(), 1))
			{
				b.server_PutOutInventory(item);
				item.setPosition(this.getPosition());
				item.IgnoreCollisionWhileOverlapped(this, 1); //somehow fixes a bug with mats falling through grinders
				item.set_u32("autopick time", getGameTime() + getTicksASecond() * 10);
				break;
			}
		}
	}
}
