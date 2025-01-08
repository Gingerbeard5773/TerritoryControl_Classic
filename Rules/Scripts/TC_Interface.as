// Custom Scoreboard

#include "ScoreboardCommon.as";

const string[] kagdevs = { "geti", "mm", "flieslikeabrick", "furai", "jrgp" };
const string[] contributors = { "cesar0", "sylw", "sjd360", "merser433" };
const string[] creators = { "tflippy" };
const string[] hosters = { "vamist" };

const u32[] teamcolours = {0xff2CAFDE, 0xffD5543F, 0xff9DCA22, 0xffD379E0, 0xffFEA53D, 0xff2EE5A2, 0xff5F84EC, 0xffC4CFA1};
//u32[] teamcolours = {0xff6666ff, 0xffff6666, 0xff33660d, 0xff621a83, 0xff844715, 0xff2b5353, 0xff2a3084, 0xff647160};

Vec2f lineoffset = Vec2f(0, -2);
const f32 stepheight = 16;

bool mousePress;

void onRenderScoreboard(CRules@ this)
{
	//sort players
	CPlayer@[] sortedplayers;
	for (u32 i = 0; i < getPlayersCount(); i++)
	{
		CPlayer@ p = getPlayer(i);
		const int team = p.getTeamNum();
		bool inserted = false;
		for (u32 j = 0; j < sortedplayers.length; j++)
		{
			if (sortedplayers[j].getTeamNum() > team)
			{
				sortedplayers.insert(j, p);
				inserted = true;
				break;
			}
		}
		if (!inserted)
			sortedplayers.push_back(p);
	}
	
	CControls@ controls = getControls();
	Vec2f mousePos = controls.getMouseScreenPos();

	//draw board

    drawServerInfo(40);
	//drawServerRules(40); //re-enable if people break rules

	Vec2f topleft(100, 150);
	Vec2f bottomright(getScreenWidth() - 100, topleft.y + (sortedplayers.length + 3.5) * stepheight);
	GUI::DrawPane(topleft, bottomright, SColor(0xffc0c0c0));
	
	makeWebsiteLink(Vec2f(getScreenWidth()/2 - 300, topleft.y - 55), "Discord Link", "https://discord.gg/V29BBeba3C", controls, mousePos);

	//offset border

	topleft.x += stepheight;
	bottomright.x -= stepheight;
	topleft.y += stepheight;

	GUI::SetFont("menu");

	//draw player table header

	GUI::DrawText("Character Name", Vec2f(topleft.x, topleft.y), SColor(0xffffffff));
	GUI::DrawText("User Name", Vec2f(topleft.x + 300, topleft.y), SColor(0xffffffff));
	// GUI::DrawText("Coins", Vec2f(bottomright.x - 600, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Ping", Vec2f(bottomright.x - 500, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Kills", Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Deaths", Vec2f(bottomright.x - 300, topleft.y), SColor(0xffffffff));
	GUI::DrawText("Title", Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));

	topleft.y += stepheight * 0.5f;
	
	//draw players
	for (u32 i = 0; i < sortedplayers.length; i++)
	{
		CPlayer@ p = sortedplayers[i];
		if (p is null) continue;

		const bool playerHover = mousePos.y > topleft.y + 10 && mousePos.y < topleft.y + 30;

		topleft.y += stepheight;
		bottomright.y = topleft.y + stepheight;

		u32 playercolour = teamcolours[p.getTeamNum() % teamcolours.length];

		if (p.getTeamNum() >= this.getTeamsCount())
		{
			playercolour = 0xffbfbfbf;
		}
		if (playerHover)
        {
            playercolour = 0xffffffff;
        }

		GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y + 1) + lineoffset, Vec2f(bottomright.x, bottomright.y + 1) + lineoffset, SColor(0xff404040));
		GUI::DrawLine2D(Vec2f(topleft.x, bottomright.y) + lineoffset, bottomright + lineoffset, SColor(playercolour));

		string tex = "";
		u16 frame = 0;
		Vec2f framesize;
		if (p.isMyPlayer())
		{
			tex = "ScoreboardIcons.png";
			frame = 4;
			framesize.Set(16, 16);
		}
		else
		{
			tex = p.getScoreboardTexture();
			frame = p.getScoreboardFrame();
			framesize = p.getScoreboardFrameSize();
		}
		if (tex != "") GUI::DrawIcon(tex, frame, framesize, topleft, 0.5f, p.getTeamNum());

		const string playername = (p.getClantag().length > 0 ? p.getClantag() + " " : "") + p.getCharacterName();
		const string username = p.getUsername();
		const string rank = getRank(p);
		const s32 ping_in_ms = s32(p.getPing() * 1000.0f / 30.0f);
		
		GUI::DrawText(playername, topleft + Vec2f(20, 0), playercolour);
		GUI::DrawText(username, topleft + Vec2f(300, 0), playercolour);

		GUI::DrawText("" + ping_in_ms, Vec2f(bottomright.x - 500, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + p.getKills(), Vec2f(bottomright.x - 400, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + p.getDeaths(), Vec2f(bottomright.x - 300, topleft.y), SColor(0xffffffff));
		GUI::DrawText("" + rank, Vec2f(bottomright.x - 200, topleft.y), SColor(0xffffffff));
	}
	
	// Vec2f offset = Vec2f(0, bottomright.y - topleft.y + 64);
	// GUI::DrawPane(topleft + offset, bottomright + offset + Vec2f(0, 64), SColor(0xffc0c0c0));
	mousePress = controls.mousePressed1; 
}

string getRank(CPlayer@ p)
{
	const string username = p.getUsername().toLower();
	const string seclev = getSecurity().getPlayerSeclev(p).getName();
	
	if (kagdevs.find(username) != -1) return "KAG Developer";
	else if (contributors.find(username) != -1) return "TC Contributor";
	else if (creators.find(username) != -1) return "TC Creator";
	else if (hosters.find(username) != -1) return "Glorious Server Host";
	else if (username == "pirate-rob") return "ROS Creator";
	else if (seclev != "Normal") seclev;
	
	return "";
}

void onInit(CRules@ this)
{
	onRestart(this);
}

void onRestart(CRules@ this)
{
	if (isServer())
	{
		getMapName(this);
	}
}

void getMapName(CRules@ this)
{
	CMap@ map = getMap();
	if (map is null) return;

	string[] name = map.getMapName().split('/');	 //Official server maps seem to show up as
	string mapName = name[name.length() - 1];		 //``Maps/CTF/MapNameHere.png`` while using this instead of just the .png
	mapName = getFilenameWithoutExtension(mapName);  // Remove extension from the filename if it exists

	this.set_string("map_name", mapName);
	this.Sync("map_name", true);
}

float drawServerRules(float y)
{
	GUI::SetFont("menu");

	Vec2f pos(getScreenWidth()/4, y);
	float width = 200;
	
	const string Rules = "Server Rules";
	const string Rule_1 = "- Do not grief or sabotage your team.";
	const string Rule_2 = "- Don't block neutral spawn.";

	SColor white(0xffffffff);
	Vec2f dim;
	GUI::GetTextDimensions(Rules, dim);
	if (dim.x + 15 > width)
		width = dim.x + 15;

	GUI::GetTextDimensions(Rule_1, dim);
	if (dim.x + 15 > width)
		width = dim.x + 15;
		
	GUI::GetTextDimensions(Rule_2, dim);
	if (dim.x + 15 > width)
		width = dim.x + 15;

	pos.x -= width/2;
	Vec2f bot = pos;
	bot.x += width;
	bot.y += 95;

	Vec2f mid(getScreenWidth()/4, y);

	GUI::DrawPane(pos, bot, SColor(0xffcccccc));

	mid.y += 15;
	GUI::DrawTextCentered(Rules, mid, white);
	mid.y += 15;
	GUI::DrawTextCentered(Rule_1, mid, white);
	mid.y += 15;
	GUI::DrawTextCentered(Rule_2, mid, white);

	return bot.y;
}

void makeWebsiteLink(Vec2f pos, const string&in text, const string&in website, CControls@ controls, Vec2f&in mousePos)
{
	GUI::SetFont("menu");
	Vec2f dim;
	GUI::GetTextDimensions(text, dim);

	const f32 width = dim.x + 20;
	const f32 height = 40;
	Vec2f tl = pos;
	Vec2f br = Vec2f(width + pos.x, pos.y + height);

	const bool hover = (mousePos.x > tl.x && mousePos.x < br.x && mousePos.y > tl.y && mousePos.y < br.y);
	if (hover)
	{
		GUI::DrawButton(tl, br);

		if (controls.mousePressed1 && !mousePress)
		{
			Sound::Play("option");
			OpenWebsite(website);
		}
	}
	else
	{
		GUI::DrawPane(tl, br, 0xffcfcfcf);
	}

	GUI::DrawTextCentered(text, Vec2f(tl.x + (width * 0.50f), tl.y + (height * 0.50f)), 0xffffffff);
}
