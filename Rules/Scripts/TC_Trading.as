#include "GameplayEventsCommon.as";
#include "CustomTiles.as";

#define SERVER_ONLY

const int coinsOnDamageAdd = 5;
const int min_coins = 50;

const int coinsOnHitSiege = 3;
const int coinsOnKillVehicle = 100;

const int coinsOnBuildStoneBlock = 1;
const int coinsOnBuildStoneDoor = 2;

const int coinsOnBuildWood = 1;

const int coinsOnBuildIronDoor = 3;
const int coinsOnBuildIron = 2;

const int coinsOnBuildPlasteel = 4;

void onInit(CRules@ this)
{
	CGameplayEvent@ func = @awardCoins;
	this.set("awardCoins handle", @func);
}

// give coins for killing

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ killer, u8 customData)
{
	if (victim !is null)
	{
		CBlob@ victimBlob = victim.getBlob();
	
		bool took = false;
		if (killer !is null)
		{
			if (killer !is victim && killer.getTeamNum() != victim.getTeamNum())
			{
				killer.server_setCoins(killer.getCoins() + (victim.getCoins() * 0.1f));
				took = true;
			}
		}
		else if (victimBlob !is null) 
		
		server_DropCoins(victimBlob.getPosition(), victim.getCoins() * 0.1f);
		victim.server_setCoins(victim.getCoins() * (took ? 0.8f : 0.9f));
	}
}

// give coins for damage

f32 onPlayerTakeDamage(CRules@ this, CPlayer@ victim, CPlayer@ attacker, f32 DamageScale)
{
	if (attacker !is null && attacker !is victim)
	{
		CBlob@ blob = attacker.getBlob();
	
		if (blob !is null) attacker.server_setCoins(attacker.getCoins() + DamageScale * coinsOnDamageAdd / this.attackdamage_modifier + (blob.getConfig() == "bandit" ? 10 : 0));
	}

	return DamageScale;
}

// Gameplay events stuff

void awardCoins(CBitStream@ params)
{
	if (!isServer()) return;

	params.ResetBitIndex();

	u8 event_id;
	if (!params.saferead_u8(event_id)) return;

	u16 player_id;
	if (!params.saferead_u16(player_id)) return;

	CPlayer@ p = getPlayerByNetworkId(player_id);
	if (p is null) return;

	u32 coins = 0;

	if (event_id == CGameplayEvent_IDs::BuildBlock)
	{
		u16 tile;
		if (!params.saferead_u16(tile)) return;

		if (tile == CMap::tile_castle)
		{
			coins = coinsOnBuildStoneBlock;
		}
		else if (tile == CMap::tile_wood)
		{
			coins = coinsOnBuildWood;
		}
		else if (tile == CMap::tile_iron)
		{
			coins = coinsOnBuildIron;
		}
		else if (tile == CMap::tile_plasteel)
		{
			coins = coinsOnBuildPlasteel;
		}
	}
	else if (event_id == CGameplayEvent_IDs::BuildBlob)
	{
		string name;
		if (!params.saferead_string(name)) return;

		if (name == "trap_block" || name == "spikes")
		{
			coins = coinsOnBuildStoneBlock;
		}
		else if (name == "stone_door" || name == "iron_platform")
		{
			coins = coinsOnBuildStoneDoor;
		}
		else if (name == "wooden_platform" ||
				name == "stone_halfblock" ||
				name == "stone_triangle" ||
				name == "wood_triangle" ||
				name == "wooden_door" ||
				name == "bridge" ||
				name == "ladder")
		{
			coins = coinsOnBuildWood;
		}
		else if (name == "iron_door")
		{
			coins = coinsOnBuildIronDoor;
		}
	}
	else if (event_id == CGameplayEvent_IDs::HitVehicle)
	{
		f32 damage; 
		if (!params.saferead_f32(damage)) return;

		//disabled because it could give insane amounts of coins
		//coins = coinsOnHitSiege * damage;
	}
	else if (event_id == CGameplayEvent_IDs::KillVehicle)
	{
		coins = coinsOnKillVehicle;
	}

	if (coins > 0)
	{
		p.server_setCoins(p.getCoins() + coins);
	}
}
