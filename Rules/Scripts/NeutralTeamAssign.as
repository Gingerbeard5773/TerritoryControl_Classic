//Gingerbeard @ September 10, 2024
//This system was missing so I re-implemented it. Seems to be more effective then jammers SHIT CODE from newer versions.

const u8 neutral_minimum_team = 100;

u8 getAssignedNeutralTeam(CRules@ this, const string&in username)
{
	string[]@ playernames;
	if (!this.get("assigned_neutral_teams", @playernames)) return neutral_minimum_team;
	
	const int index = playernames.length > 0 ? playernames.find(username) : -1;
	if (index <= -1)
	{
		return AssignAvailableNeutralTeam(playernames, username);
	}

	return neutral_minimum_team + index;
}

u8 AssignAvailableNeutralTeam(string[]@ playernames, const string&in username)
{
	const u8 playerslength = playernames.length;
	for (u8 i = 0; i < playerslength; i++)
	{
		CPlayer@ p = getPlayerByUsername(playernames[i]);
		if (p is null)
		{
			playernames[i] = username;
			return neutral_minimum_team + i;
		}
	}
	
	playernames.push_back(username);
	return neutral_minimum_team + playerslength;
}
