#include "Hitters.as";
#include "ExplosionDelay.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(Translate::Methane);
	this.Tag("explosive");
	this.maxQuantity = 50;
}

void onDie(CBlob@ this)
{
	if (this.hasTag("doExplode"))
	{
		DoExplosion(this);
	}
}

void DoExplosion(CBlob@ this)
{
	this.getSprite().PlaySound("gas_leak.ogg");

	if (isServer())
	{
		const f32 quantity = this.getQuantity();
		for (int i = 0; i < (quantity / 5) + XORRandom(quantity / 5) ; i++)
		{
			CBlob@ blob = server_CreateBlob("methane", -1, this.getPosition());
			blob.setVelocity(Vec2f(2 - XORRandom(4), 2 - XORRandom(4)));
		}
	}

	this.getSprite().Gib();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage >= this.getHealth() || customData == Hitters::fire || customData == Hitters::burn)
	{
		server_SetBombToExplode(this, 2);
		this.Tag("doExplode");
		return 0.0f;
	}

	return damage;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !blob.isCollidable() : !solid) return;

	if (solid) this.Untag("no pickup");
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 5.0f)
	{
		server_SetBombToExplode(this, 2);
		this.Tag("doExplode");
	}
}
