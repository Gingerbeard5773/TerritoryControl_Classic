#define SERVER_ONLY

#include "BrainPathing.as";
#include "SquadCommon.as";

Squad@[] squads;
int used_squads = 0;

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
	squads.clear();
	this.set_u32("next_meteor", getNextMeteor());
	this.set_u32("next_wreckage", getNextWreckage());
	this.set_u32("next_chicken_attack", 60);
}

u32 getNextMeteor()
{
	return 6000 + XORRandom(29000);
}

u32 getNextWreckage()
{
	return 60000 + XORRandom(80000);
}

u32 getNextAttack()
{
	return 30*60 + XORRandom(30*60);
}

void onTick(CRules@ this)
{
	if (getGameTime() % 30 == 0)
	{
		CMap@ map = getMap();
		const u32 time = getGameTime();
		const u32 nextMeteor = this.get_u32("next_meteor");
		const u32 nextWreckage = this.get_u32("next_wreckage");
		const u32 nextAttack = this.get_u32("next_chicken_attack");

		if (time >= nextMeteor)
		{
			print("Random event: Meteor");
			CBlob@ blob = server_CreateBlobNoInit("meteor");
			if (blob !is null)
			{
				blob.setPosition(Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));
				blob.Tag("explosive");
				blob.Init();
			}

			this.set_u32("next_meteor", time + getNextMeteor());
		}

		if (time >= nextWreckage)
		{
			print("Random event: Wreckage");
			CBlob@ blob = server_CreateBlobNoInit("ancientship");
			if (blob !is null)
			{
				blob.setPosition(Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));
				blob.Tag("explosive");
				blob.Init();
			}

			this.set_u32("next_wreckage", time + getNextWreckage());
		}
		
		if (time >= nextAttack)
		{
			WarManager();
			this.set_u32("next_chicken_attack", time + getNextAttack());
		}
		
		getHighestFactionMembershipRatio();
	}
}

void WarManager()
{
	SetupSquads();
	
	UpdateSquadIntegrity();
	
	if (squads.length == 0) return;

	used_squads = 0;

	DefendCoops();
	
	const f32 ratio = getHighestFactionMembershipRatio();
	const f32 probability = 0.25f + (ratio - 0.65f) * 2.14f;
	if (getGameTime() > 30 * 60 * 8 && XORRandom(100) < probability * 100)
	{
		SendSquadsToWar();
	}
	
	ResumeWar();
}

f32 getHighestFactionMembershipRatio()
{
	const int teams_count = getRules().getTeamsCount();
	int[] teams_players(teams_count);
	int total_team_players = 0;
	const int player_count = getPlayerCount();
	for (int i = 0; i < player_count; i++)
	{
		CPlayer@ player = getPlayer(i);
		const int team = player.getTeamNum();
		if (team < teams_count)
		{
			total_team_players++;
			teams_players[team]++;
		}
	}
	
	if (total_team_players == 0) return 0.0f;
	
	f32 highest_ratio = 0.0f;
	for (int i = 0; i < teams_count; i++)
	{
		const f32 ratio = f32(teams_players[i]) / total_team_players;
		if (ratio > highest_ratio)
		{
			highest_ratio = ratio;
		}
	}

	return highest_ratio;
}

void SetupSquads()
{
	CBlob@[] chickens;
	if (!getBlobsByTag("combat chicken", @chickens)) return;
	
	CBlob@[] available;
	for (int i = 0; i < chickens.length; i++)
	{
		CBlob@ blob = chickens[i];
		if (blob.exists("squad")) continue;
		
		available.push_back(blob);
	}
	
	//resupply existing squads
	if (available.length != 0)
	{
		for (int i = 0; i < squads.length; i++)
		{
			Squad@ squad = squads[i];
			while (squad.getBlobs().length < 3 && available.length > 0)
			{
				squad.member_netids.push_back(available[0].getNetworkID());
				available.erase(0);
			}
		}
	}
	
	//build new squads
	while (available.length >= 3)
	{
		Squad squad();
		const int squad_size = Maths::Min(4, available.length);
		for (int i = squad_size - 1; i >= 0; i--)
		{
			CBlob@ blob = available[i];
			squad.member_netids.push_back(blob.getNetworkID());
			blob.set("squad", @squad);
			available.erase(i);
		}
		squads.push_back(@squad);
	}
}

void UpdateSquadIntegrity()
{
	for (int i = squads.length - 1; i >= 0; i--)
	{
		Squad@ squad = squads[i];
		if (squad.getBlobs().length == 0)
		{
			@squad = null;
			squads.erase(i);
		}
	}
}

void DefendCoops()
{
	CBlob@[] coops;
	if (!getBlobsByName("chickencoop", @coops)) return;
	
	for (int i = 0; i < coops.length && i < squads.length; i++)
	{
		CBlob@ coop = coops[i];
		Squad@ squad = squads[i];
		squad.target_netid = 0;
		squad.task = SquadTask::DEFEND;
		squad.destination = coop.getPosition();
		squad.destination_threshold = 8 * 25;
		used_squads++;
	}
}

void SendSquadsToWar()
{
	for (int i = used_squads; i < squads.length; i++)
	{
		Squad@ squad = squads[i];		
		if (squad.getTarget() !is null && squad.task == SquadTask::ATTACK) continue;
		
		DeploySquad(squad);
	}
}

void ResumeWar()
{
	for (int i = 0; i < squads.length; i++)
	{
		Squad@ squad = squads[i];
		if (squad.task != SquadTask::ATTACK && squad.task != SquadTask::PATROL) continue;

		if (squad.getTarget() !is null && squad.task == SquadTask::ATTACK) continue;
		
		DeploySquad(squad);
	}
}

void DeploySquad(Squad@ squad)
{
	CBlob@ leader = squad.getBlobs()[0];

	CBlob@ fort = getFortToAttack(leader.getPosition());
	if (fort is null)
	{
		Vec2f dim = getMap().getMapDimensions();
		squad.target_netid = 0;
		squad.task = SquadTask::PATROL;
		squad.destination = Vec2f(XORRandom(dim.x), XORRandom(dim.y));
		squad.destination_threshold = 8 * 20;
		return;
	}

	squad.target_netid = fort.getNetworkID();
	squad.task = SquadTask::ATTACK;
	squad.destination = fort.getPosition();
	squad.destination_threshold = 32.0f;
}

CBlob@ getFortToAttack()
{
	CBlob@[] forts;
	if (getBlobsByTag("faction_base", @forts))
	{
		return forts[XORRandom(forts.length)];
	}
	return null;
}

int getMegaFaction()
{
	const int teams_count = getRules().getTeamsCount();
	int[] teams_players(teams_count);
	
	const int player_count = getPlayerCount();
	for (int i = 0; i < player_count; i++)
	{
		CPlayer@ player = getPlayer(i);
		const int team = player.getTeamNum();
		if (team < teams_count)
		{
			teams_players[team]++;
		}
	}
	
	int biggest_team = 0;
	for (int i = 0; i < teams_count; i++)
	{
		if (teams_players[i] > teams_players[biggest_team])
		{
			biggest_team = i;
		}
	}
	
	if (teams_players[biggest_team] == 0)
	{
		CBlob@[] forts;
		if (getBlobsByTag("faction_base", @forts))
		{
			return forts[0].getTeamNum();
		}
		return -1;
	}
	
	return biggest_team;
}

CBlob@ getFortToAttack(Vec2f&in position)
{
	const int biggest_team = getMegaFaction();
	if (biggest_team == -1) return null;
	
	CBlob@[] forts;
	if (!getBlobsByTag("faction_base", @forts)) return null;
	
	CBlob@[] megafaction_forts;
	for (u16 i = 0; i < forts.length; i++)
	{
		CBlob@ fort = forts[i];
		if (fort.getTeamNum() == biggest_team)
		{
			megafaction_forts.push_back(fort);
		}
	}
	
	CBlob@ closestFort = null;
	f32 closestDist = 999999.0f;

	for (u16 i = 0; i < megafaction_forts.length; i++)
	{
		CBlob@ fort = megafaction_forts[i];
		const f32 dist = (fort.getPosition() - position).Length();
		if (dist < closestDist)
		{
			closestDist = dist;
			@closestFort = fort;
		}
	}

	return closestFort;
}

