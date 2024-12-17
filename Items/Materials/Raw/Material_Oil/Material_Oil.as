#include "Hitters.as";
#include "Explosion.as";
#include "ExplosionDelay.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(Translate::Oil);
	this.set_u8("custom_hitter", Hitters::fire);
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
	Explode(this, 16.0f, 2.0f);

	if (isServer())
	{
		const f32 quantity = this.getQuantity();
		for (int i = 0; i < (quantity / 10) + XORRandom(quantity / 10) ; i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
			blob.setVelocity(Vec2f(XORRandom(10) - 5, -XORRandom(6)));
			blob.server_SetTimeToDie(4 + XORRandom(6));
		}
	}

	this.getSprite().Gib();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn || isExplosionHitter(customData) || damage >= this.getHealth())
	{
		server_SetBombToExplode(this);
		return 0.0f;
	}

	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable() && !blob.hasTag("gas");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !doesCollideWithBlob(this, blob) || (blob.isPlatform() && !solid) : !solid) return;

	if (solid) this.Untag("no pickup");
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 5.0f)
	{
		server_SetBombToExplode(this);
	}
}
