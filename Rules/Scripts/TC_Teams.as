//Gingerbeard @ November 14, 2024

#include "TeamsCommon.as";
#include "TC_Translation.as";

const u16 leader_expiration_seconds = 60 * 2;

void onInit(CRules@ this)
{
	this.addCommandID("client_sync_teams");
	this.addCommandID("client_reset_leadership");

	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	TeamData@[] teams;
	const u8 teamsCount = this.getTeamsCount();
	for(u8 i = 0; i < teamsCount; i++)
	{
		teams.push_back(TeamData());
	}
	this.set("TeamData", @teams);
}

void onTick(CRules@ this)
{
	if (!isServer()) return;

	if (getGameTime() % 30 != 0) return;

	TeamData@[]@ teams;
	if (!this.get("TeamData", @teams)) return;

	for(u8 i = 0; i < teams.length; i++)
	{
		TeamData@ teamdata = teams[i];
		if (teamdata.leader_name.isEmpty()) continue;

		CPlayer@ leader = getPlayerByUsername(teamdata.leader_name);
		if (leader !is null)
		{
			teamdata.leader_expiration = 0;
			continue;
		}

		if (teamdata.leader_expiration >= leader_expiration_seconds)
		{
			teamdata.leader_name = "";
			CBitStream stream;
			stream.write_u8(i);
			this.SendCommand(this.getCommandID("client_reset_leadership"), stream);
			continue;
		}

		teamdata.leader_expiration++;
	}
}

void onNewPlayerJoin(CRules@ this, CPlayer@ player)
{
	if (!isServer()) return;

	CBitStream stream;
	SerializeTeams(this, stream);
	this.SendCommand(this.getCommandID("client_sync_teams"), stream, player);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client_sync_teams") && isClient())
	{
		UnserializeTeams(this, params);
	}
	else if (cmd == this.getCommandID("client_reset_leadership") && isClient())
	{
		const u8 team = params.read_u8();
		TeamData@ teamdata = getTeamData(team);
		teamdata.leader_name = "";
		CPlayer@ localPlayer = getLocalPlayer();
		if (localPlayer !is null && localPlayer.getTeamNum() == team)
		{
			client_AddToChat(Translate::LeaderReset, SColor(0xff444444));
		}
	}
}
