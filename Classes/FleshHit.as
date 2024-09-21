// Flesh hit

#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("flesh");
}

f32 getGibHealth(CBlob@ this)
{
	if (this.exists("gib health"))
	{
		return this.get_f32("gib health");
	}

	return 0.0f;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::fire:
			damage *= 1.5f;
			break;
		
		case Hitters::burn:
			damage *= 1.25f;
			break;
	
		default:
			break;
	}

	this.Damage(damage, hitterBlob);

	f32 gibHealth = getGibHealth(this);

	if (this.getHealth() <= gibHealth)
	{
		this.getSprite().Gib();
		this.server_Die();
	}

	return 0.0f; //done, we've used all the damage
}
