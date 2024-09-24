#include "Hitters.as";
#include "Explosion.as";
#include "ExplosionDelay.as";

void onInit(CBlob@ this)
{
	if (isServer())
	{
		this.set_u8("decay step", 3);
	}
	
	this.maxQuantity = 100;
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
	const f32 quantity = this.getQuantity();
	
	Sound::Play("KegExplosion.ogg", this.getPosition());

	Random rand(this.getNetworkID());
	const u8 explosion_count = 2 + rand.NextRanged(3);
	for (u8 i = 0; i < explosion_count; i++)
	{
		Vec2f dir = Vec2f((100 - int(rand.NextRanged(200))) / 100.0f, (100 - int(rand.NextRanged(200))) / 100.0f);
		LinearExplosion(this, dir, 1.1f * quantity, 0.2f * quantity, 4, 8.0f, Hitters::explosion, false, true);
	}

	this.getSprite().Gib();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn || isExplosionHitter(customData))
	{
		server_SetBombToExplode(this);
		this.Tag("doExplode");
		return 0.0f;
	}

	return damage;
}
