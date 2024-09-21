#include "Hitters.as";
#include "KnockedCommon.as";

//necessary to be able to not take damage while in vehicles
f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player = this.getPlayer();
	if (this.hasTag("invincible") || (player !is null && player.freeze))
	{
		return 0.0f;
	}

	//knocked players cant suicide
	if (customData == Hitters::suicide && isKnocked(this))
	{
		return 0.0f;
	}

	return damage;
}
