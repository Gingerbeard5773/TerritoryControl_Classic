#include "Hitters.as";
#include "GameplayEventsCommon.as";

/*f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	if (dmg > 0 && hitterBlob !is null && hitterBlob !is this && isServer())
	{
		CPlayer@ damageowner = hitterBlob.getDamageOwnerPlayer();
		if (damageowner !is null && damageowner.getTeamNum() != this.getTeamNum())
		{
			GE_HitVehicle(damageowner.getNetworkID(), dmg); // gameplay event for coins
		}
	}

	return dmg;
}*/

void onDie(CBlob@ this)
{
	CPlayer@ damageowner = this.getPlayerOfRecentDamage();
	if (damageowner !is null && damageowner.getTeamNum() != this.getTeamNum() && isServer())
	{
		GE_KillVehicle(damageowner.getNetworkID());
	}
}
