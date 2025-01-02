//Gingerbeard rewrote this script.
//I could have used the base kag system but im lazy as hell. sue me.

// Chat Commands for TC

//Commands sorted by
// Player: all players can use these commands
// Moderator: only moderators can use these commands
// Developer: only TC geniuses can use these commands

#include "MakeSeed.as";
#include "MakeCrate.as";

const string[] isCool = { "MrHobo", "Pirate-Rob", "GoldenGuy", "Vamist" };

bool onServerProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (player is null) return true;
	
	CBlob@ blob = player.getBlob();
	if (blob is null) return true;
	
	string message;
	//SColor color = ConsoleColour::ERROR;
	
	if (text_in.substr(0, 1) == "!")
	{
		string[]@ tokens = text_in.split(" ");

		CSecurity@ sec = getSecurity();
		const string role = sec.getPlayerSeclev(player).getName();
		const bool isLocalhost = isServer() && isClient();
		const bool isDev = isCool.find(player.getUsername()) != -1 || isLocalhost || player.isMod() || player.isRCON() || role == "Super Admin";
		const bool isMod = isDev || role == "Admin" || sec.checkAccess_Command(player, "ban");
		
		if (!PlayerCommands(this, tokens, player, blob, message))
			return false;

		if (isMod && message.isEmpty() && !ModeratorCommands(this, tokens, player, blob, message))
			return false;

		if (isDev && message.isEmpty() && !DeveloperCommands(this, tokens, player, blob, message))
			return false;
	}

	if (message != "") // send message to client
	{
		CBitStream stream;
		stream.write_string(message);

		// List is reverse so we can read it correctly into SColor when reading
		//stream.write_u8(color.getBlue());
		//stream.write_u8(color.getGreen());
		//stream.write_u8(color.getRed());
		//stream.write_u8(color.getAlpha());

		this.SendCommand(this.getCommandID("client_SendPlayerMessage"), stream, player);
		return false;
	}

	return true;
}

bool PlayerCommands(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, string &out message)
{
	if (tokens[0] == "!write" && tokens.length > 1) 
	{
		if (getGameTime() <= player.get_u32("nextwrite"))
		{
			player.set_u32("nextwrite", getGameTime() + 30);
			message = "Wait and try again.";
			return true;
		}
		
		if (player.getCoins() < 50)
		{
			message = "Not enough coins!";
			return true;
		}
		
		string text = "";
		for (int i = 1; i < tokens.length; i++) text += tokens[i] + " ";
		text = text.substr(0, text.length - 1);

		Vec2f dimensions;
		GUI::GetTextDimensions(text, dimensions);

		if (dimensions.x >= 250)
		{
			message = "Your text is too long, therefore it doesn't fit on the paper.";
			return true;
		}

		CBlob@ paper = server_CreateBlobNoInit("paper");
		paper.setPosition(blob.getPosition());
		paper.server_setTeamNum(blob.getTeamNum());
		paper.set_string("text", text);
		paper.Init();

		player.server_setCoins(player.getCoins() - 50);
		player.set_u32("nextwrite", getGameTime() + 100);

		message = "Written: " + text;
		return true;
	}

	return true;
}

bool ModeratorCommands(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, string &out message)
{
	if (tokens[0] == "!admin")
	{
		server_SetGrandpa(blob, player);
		return false;
	}
	else if (tokens[0] == "!tp")
	{
		if (tokens.length < 2) return false;
		
		CPlayer@ toPlayer =	GetPlayer(tokens[1]);
		if (toPlayer is null) return false;
		
		CBlob@ toBlob = toPlayer.getBlob();
		if (toBlob is null) return false;
		
		CBlob@ fromBlob = server_SetGrandpa(blob, player);
		fromBlob.setPosition(toBlob.getPosition());

		CBitStream stream;
		stream.write_netid(fromBlob.getNetworkID());
		stream.write_netid(toBlob.getNetworkID());
		this.SendCommand(this.getCommandID("client_Teleport"), stream);
		return false;
	}
	else if (tokens[0] == "!tphere")
	{
		if (tokens.length < 2) return false;
		
		CPlayer@ fromPlayer = GetPlayer(tokens[1]);
		if (fromPlayer is null) return false;
		
		CBlob@ fromBlob = fromPlayer.getBlob();
		if (fromBlob is null) return false;
		
		fromBlob.setPosition(blob.getPosition());
		
		CBitStream stream;
		stream.write_netid(fromBlob.getNetworkID());
		stream.write_netid(blob.getNetworkID());
		this.SendCommand(this.getCommandID("client_Teleport"), stream);
		return false;
	}
	else if (tokens[0] == "!freeze")
	{
		if (tokens.length < 2) return false;
		
		CPlayer@ user = GetPlayer(tokens[1]);
		if (user !is null)
		{
			user.freeze = !user.freeze;
			message = user.getUsername()+" (IP:"+user.server_getIP()+") has been "+(user.freeze ? "frozen" : "unfrozen");
			return true;
		}

		return false;
	}
	else if (tokens[0] == "!kick")
	{
		if (tokens.length < 2) return false;
		
		CPlayer@ user = GetPlayer(tokens[1]);
		if (user !is null)
		{
			message = user.getUsername()+" (IP:"+user.server_getIP()+") has been kicked";
			KickPlayer(user);
			return true;
		}

		return false;
	}
	else if (tokens[0] == "!ban")
	{
		if (tokens.length < 3) return false;
		
		CPlayer@ user = GetPlayer(tokens[1]);
		if (user !is null)
		{
			message = user.getUsername()+" (IP:"+user.server_getIP()+") has been banned";
			BanPlayer(user, parseInt(tokens[2]));
			return true;
		}

		return false;
	}

	return true;
}

bool DeveloperCommands(CRules@ this, string[]@ tokens, CPlayer@ player, CBlob@ blob, string &out message)
{
	if (tokens[0] == "!test")
	{
		sv_test = !sv_test;
		message = "Server testing mode: "+(sv_test ? "ON" : "OFF");
		return true;
	}
	else if (tokens[0] == "!team")
	{
		if (tokens.length < 2) return false;
		
		if (tokens.length > 2)
		{
			CPlayer@ user = GetPlayer(tokens[1]);
			if (user !is null)
			{
				const int team = parseInt(tokens[2]);
				user.server_setTeamNum(team);
				CBlob@ userBlob = user.getBlob();
				if (userBlob !is null)
					userBlob.server_setTeamNum(team);
			}
			return false;
		}

		const int team = parseInt(tokens[1]);
		blob.server_setTeamNum(team);
		player.server_setTeamNum(team);
		return false;
	}
	else if (tokens[0] == "!teambot")
	{
		CPlayer@ bot = AddBot("gregor_builder");
		bot.server_setTeamNum(player.getTeamNum());

		CBlob@ newBlob = server_CreateBlob("builder", player.getTeamNum(), blob.getPosition());
		newBlob.server_SetPlayer(bot);
		return false;
	}
	else if (tokens[0] == "!class")
	{
		if (tokens.length < 2) return false;

		CBlob@ newBlob = server_CreateBlob(tokens[1], blob.getTeamNum(), blob.getPosition());
		if (newBlob !is null)
		{
			CInventory@ inv = blob.getInventory();
			if (inv !is null)
			{
				blob.MoveInventoryTo(newBlob);
			}
			newBlob.server_SetPlayer(player);
			blob.server_Die();
			return false;
		}
	}
	else if (tokens[0] == "!cursor")
	{
		if (tokens.length < 2) return false;
		const u16 amount = tokens.length == 3 ? parseInt(tokens[2]) : 1;
		for (u16 i = 0; i < amount; i++)
		{
			CBlob@ newBlob = server_CreateBlob(tokens[1], blob.getTeamNum(), blob.getAimPos());
		}
		return false;
	}
	else if (tokens[0] == "!ripserver")
	{
		error("SERVER SHUT OFF by "+ player.getUsername());
		QuitGame();
		return false;
	}
	
	return true;
}

bool onClientProcessChat(CRules@ this, const string& in text_in, string& out text_out, CPlayer@ player)
{
	if (text_in == "!fps")
	{
		if (player.isMyPlayer())
		{
			const int showfps = v_showfps == 1 ? 0 : 1;
			v_showfps = showfps;
			client_AddToChat("Show FPS: " + (v_showfps == 1), color_black);
		}
		return false;
	}

	return true;
}

void onInit(CRules@ this)
{
	this.addCommandID("client_SendPlayerMessage");
	this.addCommandID("client_Teleport");
	
	const SColor print_col(0xff66C6FF);

	print("Loaded TC Chat Commands", print_col);
	print("Player Commands: !write, !fps", print_col);
	print("Moderator Commands: !admin, !tp, !tphere, !freeze, !kick, !ban", print_col);
	print("Developer Commands: !test, !team, !teambot, !class, !cursor, !ripserver", print_col);
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client_SendPlayerMessage") && isClient())
	{
		const string errorMessage = params.read_string();
		//SColor col = SColor(params.read_u8(), params.read_u8(), params.read_u8(), params.read_u8());
		client_AddToChat(errorMessage, ConsoleColour::ERROR);
	}
	else if (cmd == this.getCommandID("client_Teleport") && isClient())
	{
		CBlob@ fromBlob = getBlobByNetworkID(params.read_netid());
		CBlob@ toBlob = getBlobByNetworkID(params.read_netid());
		if (fromBlob is null || toBlob is null) return;

		Vec2f teleportPosition = toBlob.getPosition();
		fromBlob.setPosition(teleportPosition);
		ParticleZombieLightning(teleportPosition);
	}
}

CPlayer@ GetPlayer(string&in username)
{
	username = username.toLower();
	for (int i = 0; i < getPlayerCount(); i++)
	{
		CPlayer@ player = getPlayer(i);
		if (player.getUsername().toLower() == username || (username.length() >= 3 && player.getUsername().toLower().findFirst(username, 0) == 0))
		{
			return player;
		}
	}

	return null;
}

CBlob@ server_SetGrandpa(CBlob@ blob, CPlayer@ player)
{
	if (blob.getName() == "grandpa") return blob;

	CBlob@ grandpa = server_CreateBlob("grandpa", blob.getTeamNum(), blob.getPosition());
	if (grandpa !is null)
	{
		grandpa.server_SetPlayer(player);
		blob.server_Die();
		return grandpa;
	}

	return blob;
}
