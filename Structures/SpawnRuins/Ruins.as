// Ruins.as

#include "TeamsCommon.as";
#include "TC_Translation.as";

const f32 faction_detection_radius = 270.0f;
const u8 minimum_player_count_to_disable_spawn = 2;

void onInit(CBlob@ this)
{
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 27, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	this.getShape().SetStatic(true);
	this.getShape().getConsts().mapCollisions = false;

	this.getSprite().SetZ(-50.0f);   // push to background
	
	this.set_bool("isActive", true);
	this.set_u32("last_toggled_time", 0);

	this.getCurrentScript().tickFrequency = 300;
	
	this.addCommandID("server_toggle_spawn");
	this.addCommandID("client_toggle_spawn");
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	u8 team = 255;

	CBlob@[] blobs;
	if (getBlobsByName("fortress", @blobs))
	{
		Vec2f pos = this.getPosition();
		
		const u8 teams_count = getRules().getTeamsCount();
		u8[] team_player_counts(teams_count);

		const u8 playerCount = getPlayersCount();
		for (u8 i = 0; i < playerCount; i++)
		{
			CPlayer@ p = getPlayer(i);
			const u8 player_team = p.getTeamNum();
			if (player_team < teams_count)
			{
				team_player_counts[player_team]++;
			}
		}

		u8 most_players = minimum_player_count_to_disable_spawn - 1;
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if ((b.getPosition() - pos).LengthSquared() < (faction_detection_radius * faction_detection_radius))
			{
				const u8 fortress_team = b.getTeamNum();
				if (fortress_team < teams_count && team_player_counts[fortress_team] > most_players)
				{
					team = fortress_team;
					most_players = team_player_counts[fortress_team];
				}
			}
		}
	}
	
	if (team != this.getTeamNum())
	{
		this.server_setTeamNum(team);
	}
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	if (this.getTickSinceCreated() < 30) return; //map saver hack

	if (this.getTeamNum() < getRules().getTeamsCount())
	{
		this.getSprite().PlaySound("/VehicleCapture");
	}
	
	ToggleSpawn(this, true, !this.get_bool("isActive"));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	const u8 team = this.getTeamNum();
	const u8 caller_team = caller.getTeamNum();
	if (team >= getRules().getTeamsCount() || team != caller_team) return;
	
	TeamData@ teamdata = getTeamData(caller_team);
	if (teamdata is null) return;
	
	CPlayer@ player = caller.getPlayer();
	if (player is null || player.getUsername() != teamdata.leader_name) return;

	if (this.get_u32("last_toggled_time") > getGameTime() - 60) return; //dont allow spam
	
	const string toggle_message = this.get_bool("isActive") ? Translate::ToggleSpawn1 : Translate::ToggleSpawn0;
	caller.CreateGenericButton(11, Vec2f_zero, this, this.getCommandID("server_toggle_spawn"), toggle_message);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server_toggle_spawn") && isServer())
	{
		const bool active = this.get_bool("isActive");
		this.set_bool("isActive", !active);

		CBitStream stream;
		stream.write_bool(!active);
		this.SendCommand(this.getCommandID("client_toggle_spawn"), stream);
	}
	else if (cmd == this.getCommandID("client_toggle_spawn") && isClient())
	{
		bool active;
		if (!params.saferead_bool(active)) return;
		
		this.set_u32("last_toggled_time", getGameTime());

		ToggleSpawn(this, active, true);
	}
}

void ToggleSpawn(CBlob@ this, const bool&in active, const bool&in effects = false)
{
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", active ? 27 : 28, Vec2f(8, 8));
	this.set_bool("isActive", active);
	
	this.getSprite().SetFrameIndex(active ? 0 : 1);
	
	if (effects)
	{
		this.getSprite().PlaySound("/BuildingExplosion", 0.8f, 0.8f);

		Vec2f pos = this.getPosition() - Vec2f((this.getWidth() / 2) - 8, (this.getHeight() / 2) - 8);

		for (int y = 0; y < this.getHeight(); y += 16)
		{
			for (int x = 0; x < this.getWidth(); x += 16)
			{
				if (XORRandom(100) < 75) 
				{
					ParticleAnimated("Smoke.png", pos + Vec2f(x + (8 - XORRandom(16)), y + (8 - XORRandom(16))), Vec2f((100 - XORRandom(200)) / 100.0f, 0.5f), 0.0f, 1.5f, 3, 0.0f, true);
				}
			}
		}
	}
}

bool onReceiveCreateData(CBlob@ this, CBitStream@ stream)
{
	ToggleSpawn(this, this.get_bool("isActive"));
	return true;
}
