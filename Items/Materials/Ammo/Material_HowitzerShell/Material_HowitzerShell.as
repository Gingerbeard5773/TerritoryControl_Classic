#include "Hitters.as";
#include "Explosion.as";
#include "ExplosionDelay.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::HowitzerShell));
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
	if (vellen > 10.0f)
	{
		server_SetBombToExplode(this);
		this.Tag("doExplode");
	}
}

void DoExplosion(CBlob@ this)
{
	Random rand(this.getNetworkID());
	Vec2f velocity = this.getOldVelocity();

	Explode(this, 64.0f, 4.0f);
	for (u8 i = 0; i < 4; i++)
	{
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f, (int(rand.NextRanged(200)) - 100) / 200.0f);
		LinearExplosion(this, Vec2f(velocity.x * jitter.x, velocity.y * jitter.y), 24.0f + rand.NextRanged(32), 24.0f, 4, 10.0f, Hitters::explosion, false, true);
	}
	this.getSprite().Gib();
}
