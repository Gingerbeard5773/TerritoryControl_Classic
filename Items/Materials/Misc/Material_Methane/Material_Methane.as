#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 50;
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("dead")) return;

	this.getSprite().PlaySound("gas_leak.ogg");
	
	const f32 quantity = this.getQuantity();
	if (isServer())
	{
		for (int i = 0; i < (quantity / 5) + XORRandom(quantity / 5) ; i++)
		{
			CBlob@ blob = server_CreateBlob("methane", -1, this.getPosition());
			blob.setVelocity(Vec2f(2 - XORRandom(4), 2 - XORRandom(4)));
		}
	}
	
	this.Tag("dead");
	this.getSprite().Gib();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if ((customData == Hitters::fire || customData == Hitters::burn) && isServer())
	{
		this.server_Die();
	}

	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !blob.isCollidable() : !solid) return;

	if (solid) this.Untag("no pickup");
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 5.0f && isServer())
	{
		this.server_Die();
	}
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}
