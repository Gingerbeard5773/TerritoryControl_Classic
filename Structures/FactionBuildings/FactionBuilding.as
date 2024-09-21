const string raid_tag = "under raid";

void onInit(CBlob@ this)
{
	this.Tag("faction_base");
	this.Tag("ignore raid");
	this.Tag("teamlocked tunnel");
	
	this.addCommandID("faction_captured");
	this.addCommandID("faction_destroyed");
	this.addCommandID("server_join_faction");
	this.addCommandID("client_join_faction");
}

void onTick(CBlob@ this)
{
	SetMinimap(this);   //needed for under raid check
}

void SetMinimap(CBlob@ this)
{
	if (this.hasTag(raid_tag))
	{
		this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16, 16));
	}
	else
	{
		this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
		
		if (this.hasTag("minimap_large")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(16, 8));
		else if (this.hasTag("minimap_small")) this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", this.get_u8("minimap_index"), Vec2f(8, 8));
	}

	this.SetMinimapRenderAlways(true);
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	if (isServer())
	{
		CBlob@[] forts;
		getBlobsByTag("faction_base", @forts);

		const int newTeam = this.getTeamNum();
		const int totalFortCount = forts.length;
		int oldTeamForts = 0;
		int newTeamForts = 0;
		
		SetNearbyBlobsToTeam(this, oldTeam, newTeam);
		
		for (uint i = 0; i < totalFortCount; i++)
		{
			const int fortTeamNum = forts[i].getTeamNum();
			if (fortTeamNum == newTeam)        newTeamForts++;
			else if (fortTeamNum == oldTeam)   oldTeamForts++;
		}
		
		if (oldTeamForts <= 0)
		{
			CBitStream bt;
			bt.write_s32(newTeam);
			bt.write_s32(oldTeam);
			bt.write_bool(oldTeamForts == 0);

			this.SendCommand(this.getCommandID("faction_captured"), bt);

			// for (u8 i = 0; i < getPlayerCount(); i++)
			// {
				// CPlayer@ p = getPlayer(i);
				// if (p !is null && p.getTeamNum() == oldTeam)
				// {
					// p.server_setTeamNum(XORRandom(100)+100);
					// CBlob@ b = p.getBlob();
					// if (b !is null)
					// {
						// b.server_Die();
					// }
				// }
			// }
		}
	}
}

void SetNearbyBlobsToTeam(CBlob@ this, const int oldTeam, const int newTeam)
{
	CBlob@[] teamBlobs;
	getMap().getBlobsInRadius(this.getPosition(), 128.0f, @teamBlobs);

	for (uint i = 0; i < teamBlobs.length; i++)
	{
		CBlob@ b = teamBlobs[i];
		if (b.hasTag("change team on fort capture") && b.getTeamNum() == oldTeam)
		{
			b.server_setTeamNum(newTeam);
		}
	}
}

void onDie(CBlob@ this)
{
	if (this.hasTag("upgrading")) return;

	CBlob@[] forts;
	getBlobsByTag("faction_base", @forts);

	int teamForts = 0;
	const u8 team = this.getTeamNum();
	
	for (uint i = 0; i < forts.length; i++)
	{
		CBlob@ fort = forts[i];
		if (fort.getTeamNum() == team && fort !is this)
		{
			teamForts++;
		}
	}
	
	if (teamForts <= 0)
	{
		if (isServer())
		{
			CBitStream bt;
			bt.write_s32(team);
		
			this.SendCommand(this.getCommandID("faction_destroyed"), bt);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CRules@ rules = getRules();
	const u8 team = this.getTeamNum();
	const u8 teamsCount = rules.getTeamsCount();
	if (this.isOverlapping(caller) && caller.getTeamNum() >= teamsCount && team < teamsCount)
	{
		const string msg = "Join the Faction";
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("server_join_faction"), msg);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{		
	if (cmd == this.getCommandID("server_join_faction") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		CBlob@ blob = player.getBlob();
		if (blob is null) return;

		const u8 myTeam = this.getTeamNum();
		const u8 teamsCount = getRules().getTeamsCount();
		if (myTeam < teamsCount && player.getTeamNum() >= teamsCount)
		{
			const bool deserter = player.get_u32("teamkick_time") > getGameTime();
			if (!deserter)
			{
				player.server_setTeamNum(myTeam);
				CBlob@ newPlayer = server_CreateBlob("builder", myTeam, blob.getPosition());
				newPlayer.server_SetPlayer(player);
				blob.server_Die();

				this.SendCommand(this.getCommandID("client_join_faction"));
			}
		}
	}
	else if (cmd == this.getCommandID("client_join_faction") && isClient())
	{
		this.getSprite().PlaySound("party_join.ogg");
	}
	else if (cmd == this.getCommandID("faction_captured") && isClient())
	{
		CRules@ rules = getRules();
	
		const int newTeam = params.read_s32();
		const int oldTeam = params.read_s32();
		const bool defeat = params.read_bool();
		
		if (oldTeam >= rules.getTeamsCount()) return;
		
		const string oldTeamName = rules.getTeam(oldTeam).getName();
		const string newTeamName = rules.getTeam(newTeam).getName();
		
		if (defeat)
		{
			client_AddToChat(oldTeamName + " has been defeated by the " + newTeamName + "!", SColor(0xff444444));
			
			CPlayer@ ply = getLocalPlayer();
			if (oldTeam == ply.getTeamNum())
			{
				Sound::Play("FanfareLose.ogg");
			}
			else
			{
				Sound::Play("flag_score.ogg");
			}
		}
		else
		{
			client_AddToChat(oldTeamName + "'s Fortress been captured by the " + newTeamName + "!", SColor(0xff444444));
		}
	}
	else if (cmd == this.getCommandID("faction_destroyed") && isClient())
	{
		CRules@ rules = getRules();
	
		const int team = params.read_s32();
		if (team >= rules.getTeamsCount()) return;
		
		const string teamName = rules.getTeam(team).getName();
		client_AddToChat(teamName + " has been defeated!", SColor(0xff444444));
		
		CPlayer@ ply = getLocalPlayer();
		if (team == ply.getTeamNum())
		{
			Sound::Play("FanfareLose.ogg");
		}
		else
		{
			Sound::Play("flag_score.ogg");
		}
	}
}
