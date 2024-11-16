//Gingerbeard @ November 14, 2024

shared class TeamData
{
	string leader_name;         // current leader of the team
	u16 leader_expiration;      // amount of seconds that has passed from when the last leader left the game (server only)
	bool recruiting;            // decides if players can join the team
	bool lockdown;              // decides if neutrals can walk through the team's doors

	TeamData()
	{
		leader_name = "";
		leader_expiration = 0;
		recruiting = true;
		lockdown = true;
	}
}

void SerializeTeams(CRules@ this, CBitStream@ stream)
{
	TeamData@[]@ teams;
	this.get("TeamData", @teams);

	stream.write_u8(teams.length);
	for(u8 i = 0; i < teams.length; i++)
	{
		TeamData@ team = teams[i];
		stream.write_string(team.leader_name);
		stream.write_bool(team.recruiting);
		stream.write_bool(team.lockdown);
	}
}

bool UnserializeTeams(CRules@ this, CBitStream@ stream)
{
	u8 teamsLength;
	if (!stream.saferead_u8(teamsLength)) { error("Failed to synchronize team data [0]"); return false; }

	TeamData@[] teams;
	for(u8 i = 0; i < teamsLength; i++)
	{
		TeamData team();
		if (!stream.saferead_string(team.leader_name)) { error("Failed to synchronize team data [1] ["+i+"]"); return false; }
		if (!stream.saferead_bool(team.recruiting))    { error("Failed to synchronize team data [2] ["+i+"]"); return false; }
		if (!stream.saferead_bool(team.lockdown))      { error("Failed to synchronize team data [3] ["+i+"]"); return false; }
		teams.push_back(team);
	}

	this.set("TeamData", @teams);
	return true;
}

TeamData@ getTeamData(const u8&in index)
{
	TeamData@[]@ teams;
	if (getRules().get("TeamData", @teams) && index < teams.length)
	{
		return teams[index];
	}

	error("Failed to get team data for index "+index);
	return null;
}
