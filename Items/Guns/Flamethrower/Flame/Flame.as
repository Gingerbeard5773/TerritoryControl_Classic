#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(0.4f);
	this.server_SetTimeToDie(2 + XORRandom(3));
	
	this.getCurrentScript().tickFrequency = 4;
	
	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 200, 50));
}

void onTick(CBlob@ this)
{
	if (isServer() && this.getTickSinceCreated() > 5)
	{
		if (this.isInWater()) this.server_Die();

		getMap().server_setFireWorldspace(this.getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), true);
	}
}

void onTick(CSprite@ this)
{
	if (isClient())
	{
		ParticleAnimated("SmallFire.png", this.getBlob().getPosition() + Vec2f(XORRandom(16) - 8, XORRandom(16) - 8), Vec2f(0, 0), 0, 1.0f, 2, 0.25f, false);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!isServer()) return;

	if (getGameTime() % 2 != 0) return;
	
	if (this.getTickSinceCreated() < 10 && blob !is null)
	{
		CPlayer@ player = blob.getPlayer();
		if (player !is null && this.getDamageOwnerPlayer() is player)
			return;
	}

	if (solid) 
	{
		getMap().server_setFireWorldspace(point1, true);
	}
	else if (blob !is null && blob.isCollidable() && blob.getName() != this.getName())
	{
		this.server_Hit(blob, point1, normal, 0.50f, Hitters::fire, false);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.isCollidable() && blob.getShape().isStatic();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isServer() && isWaterHitter(customData))
	{
		this.server_Die();
	}

	return damage;
}
