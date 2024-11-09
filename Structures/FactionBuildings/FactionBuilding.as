#include "RemoteAccess.as";
#include "TC_Translation.as";

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
	CRules@ rules = getRules();
	const u8 team = this.getTeamNum();
	const u8 teamsCount = rules.getTeamsCount();
	if (this.isOverlapping(caller) && caller.getTeamNum() >= teamsCount && team < teamsCount)
	{
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("server_join_faction"), Translate::JoinFaction);
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
			player.server_setTeamNum(myTeam);
			CBlob@ newPlayer = server_CreateBlob("builder", myTeam, blob.getPosition());
			newPlayer.server_SetPlayer(player);
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
		if (oldTeam >= rules.getTeamsCount() || newTeam >= rules.getTeamsCount()) return;
		
		const string oldTeamName = rules.getTeam(oldTeam).getName();

		string message = Translate::Defeat.replace("{LOSER}", oldTeamName);
		if (newTeam != oldTeam)
		{
			const string newTeamName = rules.getTeam(oldTeam).getName();
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
}
