#define SERVER_ONLY
#include "MakeSeed.as";

// A tiny mod by TFlippy

const string[] seeds =
{
	//"tree_pine",
	//"tree_bushy",
	"bush",
	//"grain_plant",
	"flowers"
};

f32 tickrate = 5;

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onReload(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	CMap@ map = getMap();
	tickrate = Maths::Ceil(30 / (3 + (0.02 * map.tilemapwidth)));
}

void DecayStuff()
{
	CMap@ map = getMap();
	
	const int newPos = XORRandom(map.tilemapwidth) * map.tilesize;
	const int newLandY = map.getLandYAtX(newPos / map.tilesize) * map.tilesize;
	
	Vec2f tilePos = Vec2f(newPos, newLandY - map.tilesize);
	Vec2f offsetPos = Vec2f(tilePos.x + (XORRandom(10) - 5) * map.tilesize, tilePos.y + (XORRandom(6) - 3) * map.tilesize);
	
	Vec2f above = tilePos + Vec2f(0, -map.tilesize);
	if (map.isInWater(above)) return;
	
	const u16 tile = map.getTile(tilePos).type;
	const u16 offsetTile = map.getTile(offsetPos).type;
	
	CBlob@[] blobs;
	map.getBlobsInRadius(tilePos, 32, @blobs);
	
	if (map.isTileGround(tile))
	{
		if (map.getTile(above).type == CMap::tile_empty)
		{
			map.server_SetTile(above, CMap::tile_grass + XORRandom(3));
			if (XORRandom(2) == 0 && blobs.length < 2)
				server_MakeSeed(above, seeds[XORRandom(seeds.length)]);
		}
		
		Vec2f offsetChainPos = Vec2f(offsetPos.x + (XORRandom(2) - 1) * map.tilesize, offsetPos.y + (XORRandom(2) - 1) * map.tilesize);
		
		for (int i = 0; i < 6; i++)
		{
			if (map.getTile(offsetChainPos).type == CMap::tile_castle_back)
			{
				if (XORRandom(100) < 80)
					map.server_SetTile(offsetChainPos, CMap::tile_castle_back_moss);
			}
			else if (map.getTile(offsetChainPos).type == CMap::tile_castle)
			{
				map.server_SetTile(offsetChainPos, CMap::tile_castle_moss);
			}
			offsetChainPos = Vec2f(offsetChainPos.x + (XORRandom(2) - 1) * map.tilesize, offsetChainPos.y - (XORRandom(2)) * map.tilesize);
		}
		
		if (map.isTileCastle(offsetTile))
		{
			map.server_SetTile(offsetPos, CMap::tile_castle_moss);
		}
	}
}

void onTick(CRules@ this)
{
	if (getGameTime() % tickrate == 0)
	{
		DecayStuff();
	}
}
