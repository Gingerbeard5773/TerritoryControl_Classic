#include "RemoteAccess.as";
#include "TeamsCommon.as";
#include "TC_Translation.as";
#include "Hitters.as";

const string raid_tag = "under raid";

void onInit(CBlob@ this)
{
	this.Tag("faction_base");
	this.Tag("remote access");
	this.Tag("remote storage");
	this.Tag("ignore raid");
	this.Tag("teamlocked tunnel");
	
	this.addCommandID("client_faction_defeated");
	this.addCommandID("server_join_faction");
	this.addCommandID("client_join_faction");
	this.addCommandID("server_set_teamdata");
	this.addCommandID("client_set_teamdata");
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (isStatic)
	{
		server_ResetStorageRemoteAccess(this);
	}
}

void onTick(CBlob@ this)
{
	SetMinimap(this);   //needed for under raid check
	
	if (isServer() && (getGameTime() + this.getNetworkID() * 50) % 120 == 0 && this.getTeamNum() >= getRules().getTeamsCount())
	{
		this.server_Hit(this, this.getPosition(), Vec2f_zero, this.getInitialHealth() / 15, Hitters::crush, true);
	}
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
	if (this.getTickSinceCreated() < 30) return; //map saver hack

	server_DefeatFaction(this, oldTeam);
}

void onDie(CBlob@ this)
{
	if (this.hasTag("upgrading")) return;

	server_DefeatFaction(this, this.getTeamNum());
}

void server_DefeatFaction(CBlob@ this, const u8&in oldTeam)
{
	if (!isServer()) return;

	server_ResetStorageRemoteAccess(this);

	CBlob@[] forts;
	getBlobsByTag("faction_base", @forts);

	const u8 newTeam = this.getTeamNum();
	const u16 totalFortCount = forts.length;
	u16 oldTeamForts = 0;
	
	if (oldTeam != newTeam)
	{
		server_SetNearbyBlobsToTeam(this, oldTeam, newTeam);
	}
	
	for (u16 i = 0; i < totalFortCount; i++)
	{
		const int fortTeamNum = forts[i].getTeamNum();
		if (fortTeamNum == oldTeam)
		{
			oldTeamForts++;
		}
	}
	
	if (oldTeamForts <= 0)
	{
		CBitStream stream;
		stream.write_u8(newTeam);
		stream.write_u8(oldTeam);

		this.SendCommand(this.getCommandID("client_faction_defeated"), stream);
	}
}

void server_SetNearbyBlobsToTeam(CBlob@ this, const int oldTeam, const int newTeam)
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

void server_ResetStorageRemoteAccess(CBlob@ this)
{
	if (!isServer()) return;

	CBlob@[] blobs;
	getMap().getBlobsInRadius(this.getPosition(), remote_access_range, @blobs);
	
	for (u16 i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob.hasTag("potential remote access"))
		{
			server_SetStorageRemoteAccess(blob);
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CPlayer@ player = caller.getPlayer();
	if (player is null) return;
	
	const bool overlapping = caller.isOverlapping(this);
	const u8 team = this.getTeamNum();
	const u8 teamsCount = getRules().getTeamsCount();
	if (team >= teamsCount) return;

	TeamData@ TeamData = getTeamData(team);
	const u8 callerTeam = caller.getTeamNum();
	if (callerTeam == team && overlapping && (player.getUsername() == TeamData.leader_name || TeamData.leader_name.isEmpty()))
	{
		caller.CreateGenericButton(11, Vec2f(0, -8), this, FactionMenu, Translate::FactionManage);
	}

	if (callerTeam < teamsCount) return;

	if (!TeamData.recruiting)
	{
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, 0, Translate::CannotJoin1);
		if (button !is null) button.SetEnabled(false);
		return;
	}

	u8 factionPlayerCount = 0;
	const u8 playerCount = Maths::Max(getPlayersCount(), 1);
	if (playerCount > 4)
	{
		for (u8 i = 0; i < playerCount; i++)
		{
			CPlayer@ p = getPlayer(i);
			if (p.getTeamNum() == team)
			{
				factionPlayerCount++;
			}
		}
	}

	const f32 percent = f32(factionPlayerCount) / f32(playerCount);

	//experimental- November 13, 2024
	if (percent > 0.45f) //if the faction has more than 45% of the server player count then we cannot join
	{
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, 0, Translate::CannotJoin0);
		if (button !is null) button.SetEnabled(false);
		return;
	}

	CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("server_join_faction"), Translate::JoinFaction);
	if (button !is null) button.SetEnabled(overlapping);
}

void FactionMenu(CBlob@ this, CBlob@ caller)
{
	CPlayer@ player = caller.getPlayer();
	if (player is null) return;

	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), this, Vec2f(2, 2), Translate::FactionManage);
	if (menu is null) return;

	const u8 team = this.getTeamNum();
	TeamData@ TeamData = getTeamData(team);

	const bool isLeader = player.getUsername() == TeamData.leader_name;
	const bool recruiting = TeamData.recruiting;
	const bool lockdown = TeamData.lockdown;

	{
		CBitStream stream;
		stream.write_u8(team);
		stream.write_u8(0);
		const string message = isLeader ? name(Translate::ResignLeader) : name(Translate::ClaimLeader);
		const string icon = isLeader ? "$faction_resign_leader$" : "$faction_claim_leader$";
		CGridButton@ butt = menu.AddButton(icon, message, this.getCommandID("server_set_teamdata"), Vec2f(2, 1), stream);
		butt.hoverText = isLeader ? desc(Translate::ResignLeader) : desc(Translate::ClaimLeader);
		butt.SetEnabled(isLeader || TeamData.leader_name.isEmpty());
	}
	{
		CBitStream stream;
		stream.write_u8(team);
		stream.write_u8(1);
		const string message = (recruiting ? Translate::Disable : Translate::Enable).replace("{POLICY}", name(Translate::Recruitment));
		CGridButton@ butt = menu.AddButton("$faction_bed_" + !recruiting + "$", message, this.getCommandID("server_set_teamdata"), Vec2f(1, 1), stream);
		butt.hoverText = desc(Translate::Recruitment);
		butt.SetEnabled(isLeader);
	}
	{
		CBitStream stream;
		stream.write_u8(team);
		stream.write_u8(2);
		const string message = (lockdown ? Translate::Disable : Translate::Enable).replace("{POLICY}", name(Translate::Lockdown));
		CGridButton@ butt = menu.AddButton("$faction_lock_" + !lockdown + "$", message, this.getCommandID("server_set_teamdata"), Vec2f(1, 1), stream);
		butt.hoverText = desc(Translate::Lockdown);
		butt.SetEnabled(isLeader);
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

		const u8 team = this.getTeamNum();
		const u8 teamsCount = getRules().getTeamsCount();
		if (team < teamsCount && player.getTeamNum() >= teamsCount)
		{
			player.server_setTeamNum(team);
			CBlob@ builder = server_CreateBlob("builder", team, blob.getPosition());
			builder.server_SetPlayer(player);
			blob.MoveInventoryTo(builder);
			blob.server_Die();

			this.SendCommand(this.getCommandID("client_join_faction"));
		}
	}
	else if (cmd == this.getCommandID("client_join_faction") && isClient())
	{
		this.getSprite().PlaySound("party_join.ogg");
	}
	else if (cmd == this.getCommandID("client_faction_defeated") && isClient())
	{
		const u8 newTeam = params.read_u8();
		const u8 oldTeam = params.read_u8();

		CRules@ rules = getRules();
		if (oldTeam >= rules.getTeamsCount()) return;
		
		const string oldTeamName = rules.getTeam(oldTeam).getName();

		string message = Translate::Defeat.replace("{LOSER}", oldTeamName);
		if (newTeam != oldTeam && newTeam < rules.getTeamsCount())
		{
			const string newTeamName = rules.getTeam(newTeam).getName();
			message = Translate::Defeated.replace("{LOSER}", oldTeamName).replace("{WINNER}", newTeamName);
		}

		client_AddToChat(message, SColor(0xff444444));

		CPlayer@ localPlayer = getLocalPlayer();
		if (localPlayer !is null && oldTeam == localPlayer.getTeamNum())
		{
			Sound::Play("FanfareLose.ogg");
		}
		else
		{
			Sound::Play("flag_score.ogg");
		}
	}
	else if (cmd == this.getCommandID("server_set_teamdata") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		const string username = player.getUsername();

		const u8 team = params.read_u8();
		const u8 type = params.read_u8();
		
		CBitStream stream;
		stream.write_u8(team);
		stream.write_u8(type);

		TeamData@ TeamData = getTeamData(team);

		switch(type)
		{
			case 0:
			{
				TeamData.leader_name = username == TeamData.leader_name ? "" : username;
				stream.write_string(TeamData.leader_name);
				break;
			}
			case 1:
				TeamData.recruiting = !TeamData.recruiting;
				break;
			case 2:
				TeamData.lockdown = !TeamData.lockdown;
				break;
		}

		SerializeTeams(getRules(), stream);
		this.SendCommand(this.getCommandID("client_set_teamdata"), stream);
	}
	else if (cmd == this.getCommandID("client_set_teamdata") && isClient())
	{
		const u8 team = params.read_u8();
		const u8 type = params.read_u8();

		if (type == 0)
		{
			const string username = params.read_string();
			CPlayer@ localPlayer = getLocalPlayer();
			if (localPlayer !is null && localPlayer.getTeamNum() == team)
			{
				const string message = username.isEmpty() ? Translate::LeaderReset : Translate::LeaderClaim.replace("{PLAYER}", username);
				client_AddToChat(message, SColor(0xff444444));
			}
		}

		UnserializeTeams(getRules(), params);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch(customData)
	{
		case Hitters::builder:
			damage *= 5.0f;
			break;
		case Hitters::drill:
			damage *= 5.5f;
			break;
	}
	return damage;
}
