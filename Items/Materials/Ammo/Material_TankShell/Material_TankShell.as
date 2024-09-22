#include "Hitters.as";
#include "Explosion.as";
#include "ExplosionDelay.as";

void onInit(CBlob@ this)
{
	this.Tag("explosive");
	this.maxQuantity = 4;
}

void onDie(CBlob@ this)
{
	if (this.hasTag("doExplode"))
	{
		DoExplosion(this);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage >= this.getHealth() && customData != Hitters::sword)
	{
		server_SetBombToExplode(this);
		this.Tag("doExplode");
		return 0.0f;
	}
	return damage;
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !blob.isCollidable() || (blob.isPlatform() && !solid) : !solid) return;

	if (solid) this.Untag("no pickup");
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 8.0f)
	{
		server_SetBombToExplode(this);
		this.Tag("doExplode");
	}
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	this.Tag("map_damage_dirt");
	
	const f32 quantity = this.getQuantity();

	Explode(this, 48.0f, 5.0f);
	LinearExplosion(this, this.getOldVelocity(), 48.0f * quantity, 16.0f * quantity / 2.0f, 4, 8.0f, Hitters::bomb);

	this.getSprite().Gib();
}
