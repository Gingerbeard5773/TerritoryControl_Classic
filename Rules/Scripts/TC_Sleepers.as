//Gingerbeard's sleeper system.
//This system was missing from this version so I re-implemented it.
//It is a rewrite originally from my mod Zombies Reborn that has been imported here.
//For client side effects go to Sleeper.as

#define SERVER_ONLY;

#include "KnockedCommon.as";

void onPlayerLeave(CRules@ this, CPlayer@ player)
{
	//set leaving player as sleeper
	
	CBlob@ blob = player.getBlob();
	if (blob is null) return;
	
	if (isKnockable(blob))
	{
		blob.server_SetPlayer(null);
		blob.set_string("sleeper_name", player.getUsername());
		blob.Tag("sleeper");
		blob.Sync("sleeper", true);
		setKnocked(blob, 255, true);
	}
	else
	{
		blob.server_Die();
	}
}

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	//set players to any sleepers that were loaded on the map (saved map)
	const u8 playerCount = getPlayerCount();
	for (u8 i = 0; i < playerCount; i++)
	{
		onNewPlayerJoin(this, getPlayer(i));
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	//see if joining player has a sleeper to use
	
	if (player is null) return;
	
	CBlob@[] sleepers;
	if (!getBlobsByTag("sleeper", @sleepers)) return;
	
	const u8 sleepersLength = sleepers.length;
	for (u8 i = 0; i < sleepersLength; i++)
	{
		CBlob@ sleeper = sleepers[i];
		if (!sleeper.hasTag("dead") && sleeper.get_string("sleeper_name") == player.getUsername())
		{
			CBlob@ oldBlob = player.getBlob();
			if (oldBlob !is null) oldBlob.server_Die();

			WakeupSleeper(sleeper, player);
			break;
		}
	}
}

void onTick(CRules@ this)
{
	const u32 gametime = getGameTime();
	if (gametime % 250 == 0)
	{
		KnockSleepers();
	}
}

void WakeupSleeper(CBlob@ sleeper, CPlayer@ player)
{
	player.server_setTeamNum(sleeper.getTeamNum());
	
	sleeper.server_SetPlayer(player);
	sleeper.set_string("sleeper_name", "");
	sleeper.Untag("sleeper");
	sleeper.Sync("sleeper", true);
	
	if (sleeper.exists("sleeper_coins"))
	{
		const u16 coins = sleeper.get_u16("sleeper_coins");
		if (coins > player.getCoins())
		{
			player.server_setCoins(coins);
		}
		sleeper.set_u16("sleeper_coins", 0);
	}
	
	//remove knocked
	if (isKnockable(sleeper))
	{
		sleeper.set_u8(knockedProp, 1);

		CBitStream params;
		params.write_u8(1);
		sleeper.SendCommand(sleeper.getCommandID(knockedProp), params);
	}
}

void KnockSleepers()
{
	CBlob@[] sleepers;
	if (!getBlobsByTag("sleeper", @sleepers)) return;
	
	const u8 sleepersLength = sleepers.length;
	for (u8 i = 0; i < sleepersLength; i++)
	{
		CBlob@ sleeper = sleepers[i];
		if (isKnockable(sleeper))
		{
			setKnocked(sleeper, 255, true);
		}
	}
}
