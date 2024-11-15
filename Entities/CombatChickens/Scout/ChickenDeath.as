//Chicken death

const int drop_coins = 150;

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (this.getHealth() <= 0.0f && !this.hasTag("dead"))
	{
		this.Tag("dead");
		this.getSprite().PlaySound("Wilhelm.ogg", 1.8f, 1.8f);

		this.getShape().getVars().isladder = false;
		this.getShape().getVars().onladder = false;
		this.getShape().checkCollisionsAgain = true;
		this.getShape().SetGravityScale(1.0f);

		if (isServer())
		{
			//getRules().server_BlobDie(this);

			server_DropCoins(this.getPosition(), drop_coins);

			this.server_DetachAll();

			if (XORRandom(100) < 5) server_CreateBlob("phone", -1, this.getPosition());
		}
	}
	return damage;
}
