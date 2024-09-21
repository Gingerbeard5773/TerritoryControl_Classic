// Territory Control voting

#include "VoteCommon.as"

const u32 next_teamkickvotedelay = 5 * 60 * 30;
const u32 next_kickvotedelay = 10 * 60 * 30;
const u32 next_mapvotedelay = 10 * 60 * 30;

const u32 VoteKickTime = 30 * 60 * 30;
const u32 VoteTeamKickTime = 10 * 60 * 30;

string[] teamkick_reason_string = { "Traitor", "Disobedient", "Stealing" };
string[] kick_reason_string = { "Griefer", "Hacker", "Spammer" };
string[] nextmap_reason_string = { "Map Ruined", "Stalemate", "Game Bugged" };

string teamkick_reason = teamkick_reason_string[0];
string kick_reason = kick_reason_string[0];

const string voteteamkick_server = "vote: teamkick server";
const string votekick_server = "vote: kick server";
const string votenextmap_server = "vote: nextmap server";

const string voteteamkick_client = "vote: teamkick client";
const string votekick_client = "vote: kick client";
const string votenextmap_client = "vote: nextmap client";

//set up the ids
void onInit(CRules@ this)
{
	this.addCommandID(voteteamkick_server);
	this.addCommandID(votekick_server);
	this.addCommandID(votenextmap_server);
	
	this.addCommandID(voteteamkick_client);
	this.addCommandID(votekick_client);
	this.addCommandID(votenextmap_client);
	
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	this.set_u32("next_teamkickvotetime", 0);
	this.set_u32("next_kickvotetime", 0);
	this.set_u32("next_mapvotetime", 0);
}

//VOTE TEAM KICK --------------------------------------------------------------------
//voteteamkick functors

class VoteTeamKickFunctor : VoteFunctor
{
	VoteTeamKickFunctor() {} //dont use this
	VoteTeamKickFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	void Pass(bool outcome)
	{
		if (kickplayer !is null && outcome)
		{
			CPlayer@ localplayer = getLocalPlayer();
			if (localplayer !is null && localplayer.getTeamNum() == kickplayer.getTeamNum())
			{
				client_AddToChat("Team Votekick passed! " + kickplayer.getUsername() + " will be kicked out of your team.", vote_message_colour());
			}

			if (isServer())
			{
				kickplayer.server_setTeamNum(100);
				
				CBlob@ b = kickplayer.getBlob();
				if (b !is null)
				{
					b.server_Die();
				}
			}
		}
	}
};

class VoteTeamKickCheckFunctor : VoteCheckFunctor
{
	VoteTeamKickCheckFunctor() {}//dont use this
	VoteTeamKickCheckFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	bool PlayerCanVote(CPlayer@ player)
	{
		//if (!getSecurity().checkAccess_Feature(player, "mark_player")) return false;
		return kickplayer.getTeamNum() == player.getTeamNum();
	}
};

//setting up a votekick object
VoteObject@ Create_VoteTeamKick(CPlayer@ player, CPlayer@ byplayer, const string&in reason)
{
	VoteObject vote;

	@vote.onvotepassed = VoteTeamKickFunctor(player);
	@vote.canvote = VoteTeamKickCheckFunctor(player);

	vote.title = "Team Kick " + player.getUsername() + "?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.forcePassFeature = "ban";

	CalculateVoteThresholds(vote);

	return vote;
}


//VOTE KICK --------------------------------------------------------------------
//votekick functors

class VoteKickFunctor : VoteFunctor
{
	VoteKickFunctor() {} //dont use this
	VoteKickFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	void Pass(bool outcome)
	{
		if (kickplayer !is null && outcome)
		{
			client_AddToChat("Votekick passed! " + kickplayer.getUsername() + " will be kicked out.", vote_message_colour());

			if (isServer())
				BanPlayer(kickplayer, VoteKickTime); //30 minutes ban
		}
	}
};

class VoteKickCheckFunctor : VoteCheckFunctor
{
	VoteKickCheckFunctor() {}//dont use this
	VoteKickCheckFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	bool PlayerCanVote(CPlayer@ player)
	{
		//if (!getSecurity().checkAccess_Feature(player, "mark_player")) return false;
		return true;
	}
};

class VoteKickLeaveFunctor : VotePlayerLeaveFunctor
{
	VoteKickLeaveFunctor() {} //dont use this
	VoteKickLeaveFunctor(CPlayer@ _kickplayer)
	{
		@kickplayer = _kickplayer;
	}

	CPlayer@ kickplayer;

	//avoid dangling reference to player
	void PlayerLeft(VoteObject@ vote, CPlayer@ player)
	{
		if (player is kickplayer)
		{
			client_AddToChat(player.getUsername() + " left early, acting as if they were kicked.", vote_message_colour());
			if (isServer())
			{
				getSecurity().ban(player, VoteKickTime, "Ran from vote");
			}

			CancelVote(vote);
		}
	}
};

//setting up a votekick object
VoteObject@ Create_Votekick(CPlayer@ player, CPlayer@ byplayer, const string&in reason)
{
	VoteObject vote;

	@vote.onvotepassed = VoteKickFunctor(player);
	@vote.canvote = VoteKickCheckFunctor(player);
	@vote.playerleave = VoteKickLeaveFunctor(player);

	vote.title = "Kick " + player.getUsername() + "?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.forcePassFeature = "ban";

	CalculateVoteThresholds(vote);

	return vote;
}

//VOTE NEXT MAP ----------------------------------------------------------------
//nextmap functors

class VoteNextmapFunctor : VoteFunctor
{
	VoteNextmapFunctor() {} //dont use this
	VoteNextmapFunctor(CPlayer@ player)
	{
		string charname = player.getCharacterName();
		string username = player.getUsername();
		//name differs?
		if (charname != username &&
		        charname != player.getClantag() + username &&
		        charname != player.getClantag() + " " + username)
		{
			playername = charname + " (" + player.getUsername() + ")";
		}
		else
		{
			playername = charname;
		}
	}

	string playername;
	void Pass(bool outcome)
	{
		if (outcome)
		{
			if (isServer())
			{
				LoadNextMap();
			}
		}
		else
		{
			client_AddToChat(playername + " needs to take a spoonful of cement! Play on!", vote_message_colour());
		}
	}
};

class VoteNextmapCheckFunctor : VoteCheckFunctor
{
	VoteNextmapCheckFunctor() {}

	bool PlayerCanVote(CPlayer@ player)
	{
		//if (!getSecurity().checkAccess_Feature(player, "map_vote")) return false;
		return true;
	}
};

//setting up a vote next map object
VoteObject@ Create_VoteNextmap(CPlayer@ byplayer, const string&in reason)
{
	VoteObject vote;

	@vote.onvotepassed = VoteNextmapFunctor(byplayer);
	@vote.canvote = VoteNextmapCheckFunctor();

	vote.title = "Skip to next map?";
	vote.reason = reason;
	vote.byuser = byplayer.getUsername();
	vote.forcePassFeature = "nextmap";

	CalculateVoteThresholds(vote);

	return vote;
}

//create menus for kick and nextmap

void onMainMenuCreated(CRules@ this, CContextMenu@ menu)
{
	CPlayer@ localplayer = getLocalPlayer();
	if (localplayer is null) return;

	if (Rules_AlreadyHasVote(this))
	{
		Menu::addContextItem(menu, "(Vote already in progress)", "DefaultVotes.as", "void CloseMenu()");
		Menu::addSeparator(menu);
		return;
	}
	
	const bool can_skip_wait = getSecurity().checkAccess_Feature(localplayer, "skip_votewait");
	const bool duplicate = isDuplicatePlayer(localplayer);

	//and advance context menu when clicked
	CContextMenu@ votemenu = Menu::addContextMenu(menu, "Start a Vote");
	Menu::addSeparator(menu);

	//vote options menu

	CContextMenu@ teamkickmenu = Menu::addContextMenu(votemenu, "Team Kick");
	//CContextMenu@ kickmenu = Menu::addContextMenu(votemenu, "Kick");
	CContextMenu@ mapmenu = Menu::addContextMenu(votemenu, "Next Map");
	Menu::addSeparator(votemenu); //before the back button

	TeamKickVoteMenu(teamkickmenu, this, localplayer, can_skip_wait, duplicate);
	Menu::addSeparator(teamkickmenu);
	
	//KickVoteMenu(kickmenu, this, localplayer, can_skip_wait, duplicate);
	//Menu::addSeparator(kickmenu);
	
	MapVoteMenu(mapmenu, this, localplayer, can_skip_wait, duplicate);
	Menu::addSeparator(mapmenu);
}

string getRemainingTime(const u32&in end_time)
{
	const u32 remaining_seconds = (end_time - getGameTime()) / 30;
	const u32 minutes = remaining_seconds / 60;
	const u32 seconds = remaining_seconds % 60;
	const string remaining_time = minutes > 0 ? (minutes + " minutes") : (seconds + " seconds"); 
	return remaining_time;
}

void TeamKickVoteMenu(CContextMenu@ teamkickmenu, CRules@ this, CPlayer@ localplayer, const bool&in can_skip_wait, const bool&in duplicate)
{
	/*if (!getSecurity().checkAccess_Feature(localplayer, "mark_player"))
	{
		Menu::addInfoBox(teamkickmenu, "Can't vote", "You cannot vote to team kick\n" +
		                 "players on this server\n");
		return;
	}*/
	
	if (duplicate)
	{
		const string msg = getTranslatedString("Voting to kick a player\nis not allowed when playing\nwith a duplicate instance of KAG.\n\nTry rejoining the server\nif this was unintentional.");
		Menu::addInfoBox(teamkickmenu, getTranslatedString("Can't Start Vote"), msg);
		return;
	}

	const u32 next_teamkickvotetime = this.get_u32("next_teamkickvotetime");
	if (!can_skip_wait && next_teamkickvotetime > getGameTime())
	{
		Menu::addInfoBox(teamkickmenu, getTranslatedString("Can't Start Vote"), "You can start another vote in "+getRemainingTime(next_teamkickvotetime)+".");
		return;
	}

	Menu::addInfoBox(teamkickmenu, "Vote Team Kick", "Vote to kick a player out of your faction.\n\n" +
					 "\nTo Use:\n\n" +
					 "- select a reason from the\n     list (default is traitor).\n" +
					 "- select a name from the list.\n" +
					 "- everyone in your faction votes.\n");

	Menu::addSeparator(teamkickmenu);

	//reasons
	for (u8 i = 0 ; i < teamkick_reason_string.length; ++i)
	{
		CBitStream params;
		params.write_u8(i);
		Menu::addContextItemWithParams(teamkickmenu, teamkick_reason_string[i], "DefaultVotes.as", "Callback_TeamKickReason", params);
	}

	Menu::addSeparator(teamkickmenu);

	//write all players on our team
	bool added = false;
	const u8 playerCount = localplayer.getTeamNum() >= this.getTeamsCount() ? 0 : getPlayersCount();
	for (u8 i = 0; i < playerCount; ++i)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null || player is localplayer) continue;

		const u8 player_team = player.getTeamNum();
		if (player_team != localplayer.getTeamNum()) continue;

		string descriptor = player.getCharacterName();
		if (player.getUsername() != player.getCharacterName())
			descriptor += " (" + player.getUsername() + ")";

		CContextMenu@ usermenu = Menu::addContextMenu(teamkickmenu, "Team Kick " + descriptor);
		Menu::addInfoBox(usermenu, "Team Kicking " + descriptor, "Make sure you're voting to kick\nthe person you meant.\n");
		Menu::addSeparator(usermenu);

		CBitStream params;
		params.write_u16(player.getNetworkID());
		params.write_string(teamkick_reason);
		Menu::addContextItemWithParams(usermenu, "Yes, I'm sure", "DefaultVotes.as", "Callback_TeamKick", params);
		added = true;

		Menu::addSeparator(usermenu);
	}

	if (!added)
	{
		Menu::addContextItem(teamkickmenu, "(No-one available)", "DefaultVotes.as", "void CloseMenu()");
	}
}

void KickVoteMenu(CContextMenu@ kickmenu, CRules@ this, CPlayer@ localplayer, const bool&in can_skip_wait, const bool&in duplicate)
{
	//kick menu
	/*if (!getSecurity().checkAccess_Feature(localplayer, "mark_player"))
	{
		Menu::addInfoBox(kickmenu, "Can't vote", "You cannot vote to kick\n" +
		                 "players on this server\n");
		return;
	}*/
	
	if (duplicate)
	{
		const string msg = getTranslatedString("Voting to kick a player\nis not allowed when playing\nwith a duplicate instance of KAG.\n\nTry rejoining the server\nif this was unintentional.");
		Menu::addInfoBox(kickmenu, getTranslatedString("Can't Start Vote"), msg);
		return;
	}

	const u32 next_kickvotetime = this.get_u32("next_kickvotetime");
	if (!can_skip_wait && next_kickvotetime > getGameTime())
	{
		Menu::addInfoBox(kickmenu, getTranslatedString("Can't Start Vote"), "You can start another vote in "+getRemainingTime(next_kickvotetime)+".");
		return;
	}

	Menu::addInfoBox(kickmenu, "Vote Kick", "Vote to kick a player\nout of the game.\n\n" +
					 "- use responsibly\n" +
					 "- report any abuse of this feature.\n" +
					 "\nTo Use:\n\n" +
					 "- select a reason from the\n     list (default is griefing).\n" +
					 "- select a name from the list.\n" +
					 "- everyone votes.\n");

	Menu::addSeparator(kickmenu);

	//reasons
	for (u8 i = 0 ; i < kick_reason_string.length; ++i)
	{
		CBitStream params;
		params.write_u8(i);
		Menu::addContextItemWithParams(kickmenu, kick_reason_string[i], "DefaultVotes.as", "Callback_KickReason", params);
	}

	Menu::addSeparator(kickmenu);

	bool added = false;
	for (u8 i = 0; i < getPlayersCount(); ++i)
	{
		CPlayer@ player = getPlayer(i);
		if (player is null || player is localplayer) continue;

		if (!getSecurity().checkAccess_Feature(player, "kick_immunity"))
		{
			string descriptor = player.getCharacterName();

			if (player.getUsername() != player.getCharacterName())
				descriptor += " (" + player.getUsername() + ")";

			CContextMenu@ usermenu = Menu::addContextMenu(kickmenu, "Kick " + descriptor);
			Menu::addInfoBox(usermenu, "Kicking " + descriptor, "Make sure you're voting to kick\nthe person you meant.\n");
			Menu::addSeparator(usermenu);

			CBitStream params;
			params.write_u16(player.getNetworkID());
			params.write_string(kick_reason);

			Menu::addContextItemWithParams(usermenu, "Yes, I'm sure", "DefaultVotes.as", "Callback_Kick", params);
			added = true;

			Menu::addSeparator(usermenu);
		}
	}

	if (!added)
	{
		Menu::addContextItem(kickmenu, "(No-one available)", "DefaultVotes.as", "void CloseMenu()");
	}
}

void MapVoteMenu(CContextMenu@ mapmenu, CRules@ this, CPlayer@ localplayer, const bool&in can_skip_wait, const bool&in duplicate)
{
	/*if (!getSecurity().checkAccess_Feature(localplayer, "map_vote"))
	{
		Menu::addInfoBox(mapmenu, "Can't vote", "You cannot vote to change\n" +
		                 "the map on this server\n");
		return;
	}*/
	
	if (duplicate)
	{
		const string msg = getTranslatedString("Voting for next map\nis not allowed when playing\nwith a duplicate instance of KAG.\n\nTry rejoining the server\nif this was unintentional.");
		Menu::addInfoBox(mapmenu, getTranslatedString("Can't Start Vote"), msg);
		return;
	}

	const u32 next_mapvotetime = this.get_u32("next_mapvotetime");
	if (!can_skip_wait && next_mapvotetime > getGameTime())
	{
		Menu::addInfoBox(mapmenu, getTranslatedString("Can't Start Vote"), "You can start another vote in "+getRemainingTime(next_mapvotetime)+".");
		return;
	}

	Menu::addInfoBox(mapmenu, "Vote Next Map", "Vote to change the map\nto the next in cycle.\n\n" +
					 "\nTo Use:\n\n" +
					 "- select a reason from the list.\n" +
					 "- everyone votes.\n");

	Menu::addSeparator(mapmenu);
	//reasons
	for (uint i = 0 ; i < nextmap_reason_string.length; ++i)
	{
		CBitStream params;
		params.write_string(nextmap_reason_string[i]);
		Menu::addContextItemWithParams(mapmenu, nextmap_reason_string[i], "DefaultVotes.as", "Callback_NextMap", params);
	}
}

void CloseMenu()
{
	Menu::CloseAllMenus();
}

void Callback_KickReason(CBitStream@ params)
{
	const u8 reason_id = params.read_u8();
	kick_reason = kick_reason_string[reason_id];
}

void Callback_TeamKickReason(CBitStream@ params)
{
	const u8 reason_id = params.read_u8();
	teamkick_reason = teamkick_reason_string[reason_id];
}

void Callback_TeamKick(CBitStream@ params)
{
	CloseMenu();
	getRules().SendCommand(getRules().getCommandID(voteteamkick_server), params);
}

void Callback_Kick(CBitStream@ params)
{
	CloseMenu();
	getRules().SendCommand(getRules().getCommandID(votekick_server), params);
}

void Callback_NextMap(CBitStream@ params)
{
	CloseMenu();
	getRules().SendCommand(getRules().getCommandID(votenextmap_server), params);
}

//actually setting up the votes
void onCommand(CRules@ this, u8 cmd, CBitStream @params)
{
	if (Rules_AlreadyHasVote(this)) return;

	if (cmd == this.getCommandID(voteteamkick_server) && isServer())
	{
		CPlayer@ byplayer = getNet().getActiveCommandPlayer();
		if (byplayer is null) return;

		CPlayer@ player = getPlayerByNetworkId(params.read_u16());
		if (player is null) return;
		
		this.set_u32("next_teamkickvotetime", getGameTime() + next_teamkickvotedelay);
		this.SyncToPlayer("next_teamkickvotetime", byplayer);
		
		const string reason = params.read_string();
		Rules_SetVote(this, Create_VoteTeamKick(player, byplayer, reason));
		
		CBitStream stream;
		stream.write_u16(byplayer.getNetworkID());
		stream.write_u16(player.getNetworkID());
		stream.write_string(reason);
		this.SendCommand(this.getCommandID(voteteamkick_client), stream);
	}	
	else if (cmd == this.getCommandID(votekick_server) && isServer())
	{
		CPlayer@ byplayer = getNet().getActiveCommandPlayer();
		if (byplayer is null) return;

		CPlayer@ player = getPlayerByNetworkId(params.read_u16());
		if (player is null) return;

		this.set_u32("next_kickvotetime", getGameTime() + next_kickvotedelay);
		this.SyncToPlayer("next_kickvotetime", byplayer);

		const string reason = params.read_string();
		Rules_SetVote(this, Create_Votekick(player, byplayer, reason));
		
		CBitStream stream;
		stream.write_u16(byplayer.getNetworkID());
		stream.write_u16(player.getNetworkID());
		stream.write_string(reason);
		this.SendCommand(this.getCommandID(votekick_client), stream);
	}
	else if (cmd == this.getCommandID(votenextmap_server) && isServer())
	{
		CPlayer@ byplayer = getNet().getActiveCommandPlayer();
		if (byplayer is null) return;

		this.set_u32("next_mapvotetime", getGameTime() + next_mapvotedelay);
		this.SyncToPlayer("next_mapvotetime", byplayer);

		const string reason = params.read_string();
		Rules_SetVote(this, Create_VoteNextmap(byplayer, reason));
		
		CBitStream stream;
		stream.write_u16(byplayer.getNetworkID());
		stream.write_string(reason);
		this.SendCommand(this.getCommandID(votenextmap_client), stream);
	}
	else if (cmd == this.getCommandID(voteteamkick_client) && isClient())
	{
		CPlayer@ byplayer = getPlayerByNetworkId(params.read_u16());
		if (byplayer is null) return;

		CPlayer@ player = getPlayerByNetworkId(params.read_u16());
		if (player is null) return;
		
		const string reason = params.read_string();
		Rules_SetVote(this, Create_VoteTeamKick(player, byplayer, reason));
	}
	else if (cmd == this.getCommandID(votekick_client) && isClient())
	{
		CPlayer@ byplayer = getPlayerByNetworkId(params.read_u16());
		if (byplayer is null) return;

		CPlayer@ player = getPlayerByNetworkId(params.read_u16());
		if (player is null) return;
		
		const string reason = params.read_string();
		Rules_SetVote(this, Create_Votekick(player, byplayer, reason));
	}
	else if (cmd == this.getCommandID(votenextmap_client) && isClient())
	{
		CPlayer@ byplayer = getPlayerByNetworkId(params.read_u16());
		if (byplayer is null) return;

		const string reason = params.read_string();
		Rules_SetVote(this, Create_VoteNextmap(byplayer, reason));
	}
}
