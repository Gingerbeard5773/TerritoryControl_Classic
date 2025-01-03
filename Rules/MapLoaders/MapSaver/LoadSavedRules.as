// Gingerbeard @ January 2nd, 2025

//this script MUST be the last script to be called in gamemode.cfg

#include "MapSaver.as";

const u32 autosave_interval = 3 * 30 * 60;

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	LoadSavedRules(this, getMap());
}

void onTick(CRules@ this)
{
	if (!isServer()) return;
	
	if (getGameTime() % autosave_interval == 0)
	{
		if (g_debug > 0)
			print("AUTOSAVING MAP", 0xff66C6FF);
		SaveMap(this, getMap());
	}
}
