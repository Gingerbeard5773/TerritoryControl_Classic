#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	if (isServer())
	{
		this.set_u8("decay step", 3);
	}
	
	this.set_string("custom_explosion_sound", "KegExplosion");
	this.maxQuantity = 100;
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	const f32 quantity = this.getQuantity();

	Random rand(this.getNetworkID());
	for (int i = 0; i < 2 + rand.NextRanged(3); i++)
	{
		Vec2f dir = Vec2f((100 - int(rand.NextRanged(200))) / 100.0f, (100 - int(rand.NextRanged(200))) / 100.0f);
		LinearExplosion(this, dir, 1.1f * quantity, 0.2f * quantity, 4, 8.0f, Hitters::explosion);
	}

	this.server_Die();
	this.getSprite().Gib();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData == Hitters::fire || customData == Hitters::burn || customData == Hitters::bomb || customData == Hitters::explosion || customData == Hitters::keg)
	{
		DoExplosion(this);
	}

	return damage;
}