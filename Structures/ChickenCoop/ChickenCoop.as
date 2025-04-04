﻿void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 600;

	this.server_setTeamNum(-1);

	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 26, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
}

void onTick(CBlob@ this)
{
	if (isServer() && XORRandom(100) < 40)
	{
		CBlob@[] chickens;
		getBlobsByTag("combat chicken", @chickens);
		
		CBlob@[] coops;
		getBlobsByName("chickencoop", @coops);
		
		const int player_modifier = Maths::Ceil(getPlayerCount() / 3);
		const int maximum_chickens = player_modifier + 5 + (4 * coops.length);
		if (chickens.length >= maximum_chickens) return;

		server_CreateBlob("scoutchicken", -1, this.getPosition() + Vec2f(16 - XORRandom(32), 0));
	}
}

void onDie(CBlob@ this)
{
	if (isServer())
	{
		server_DropCoins(this.getPosition(), 1000 + XORRandom(1500));
	}
}
