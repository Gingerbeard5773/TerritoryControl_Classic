#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "CustomTiles.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	if (map.getTile(offset).type > 255)
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if (blob !is null)
		{
			blob.server_Die();
		}
	}
	
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if (map.getTile(index).type > 255)
	{
		// print("Hit - Old: " + oldTileType + "; Index: " + index);
		
		switch(oldTileType)
		{
			case CMap::tile_iron:
				return CMap::tile_iron_d0;
				
			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
				return oldTileType + 1;
				
			case CMap::tile_iron_f:
				return CMap::tile_empty;
				
				
			case CMap::tile_glass:
				return CMap::tile_glass_f;
				
			case CMap::tile_glass_f:
				return CMap::tile_empty;
				
				
			case CMap::tile_plasteel:
				return CMap::tile_plasteel_d0;
				
			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
				return oldTileType + 1;
				
			case CMap::tile_plasteel_f:
				return CMap::tile_empty;
				
			case CMap::tile_matter:
				return CMap::tile_matter_d0;
				
			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
				return oldTileType + 1;
				
			case CMap::tile_matter_f:
				return CMap::tile_empty;
				
			/*case CMap::tile_brick_v0:
			case CMap::tile_brick_v1:
			case CMap::tile_brick_v2:
			case CMap::tile_brick_v3:
				return CMap::tile_brick_d0;
				
			case CMap::tile_brick_d0:
			case CMap::tile_brick_d1:
			case CMap::tile_brick_d2:
			case CMap::tile_brick_d3:
			case CMap::tile_brick_d4:
			case CMap::tile_brick_d5:
				return oldTileType + 1;
				
			case CMap::tile_brick_f:
				return CMap::tile_empty;*/
		}
	}
	
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	if (tile_new == CMap::tile_ground && isClient()) Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
	
	if (tile_new == CMap::tile_empty || tile_new == CMap::tile_ground_back)
	{
		switch(tile_old)
		{
			case CMap::tile_iron_f:     OnIronTileDestroyed(map, index);        break;
			case CMap::tile_plasteel_f: OnPlasteelTileDestroyed(map, index);    break;
			case CMap::tile_glass_f:    OnGlassTileDestroyed(map, index);       break;
			case CMap::tile_matter_f:   OnMatterTileDestroyed(map, index);      break;
		}
	}

	if (map.getTile(index).type > 255)
	{
		map.SetTileSupport(index, 10);
		
		switch(tile_new)
		{
			case CMap::tile_iron:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_iron_d0:
			case CMap::tile_iron_d1:
			case CMap::tile_iron_d2:
			case CMap::tile_iron_d3:
			case CMap::tile_iron_d4:
			case CMap::tile_iron_d5:
			case CMap::tile_iron_d6:
			case CMap::tile_iron_d7:
			case CMap::tile_iron_f:
				OnIronTileHit(map, index);
				break;
				
			case CMap::tile_glass:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_glass_f:
				OnGlassTileHit(map, index);
				break;
				
			case CMap::tile_plasteel:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
						
			case CMap::tile_plasteel_d0:
			case CMap::tile_plasteel_d1:
			case CMap::tile_plasteel_d2:
			case CMap::tile_plasteel_d3:
			case CMap::tile_plasteel_d4:
			case CMap::tile_plasteel_d5:
			case CMap::tile_plasteel_d6:
			case CMap::tile_plasteel_d7:
			case CMap::tile_plasteel_d8:
			case CMap::tile_plasteel_d9:
			case CMap::tile_plasteel_d10:
			case CMap::tile_plasteel_d11:
			case CMap::tile_plasteel_d12:
			case CMap::tile_plasteel_d13:
			case CMap::tile_plasteel_f:
				OnPlasteelTileHit(map, index);
				break;
				
			case CMap::tile_matter:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
			case CMap::tile_matter_f:
				OnMatterTileHit(map, index);
				break;
				
			/*case CMap::tile_brick_v0:
			case CMap::tile_brick_v1:
			case CMap::tile_brick_v2:
			case CMap::tile_brick_v3:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_brick_d0:
			case CMap::tile_brick_d1:
			case CMap::tile_brick_d2:
			case CMap::tile_brick_d3:
			case CMap::tile_brick_d4:
			case CMap::tile_brick_d5:
			case CMap::tile_brick_f:
				OnBrickTileHit(map, index);
				break;*/
		}
	}
}

void OnIronTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
		sparks(pos, 1, 1);
	}
}

void OnIronTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.0f);
	}
}

void OnGlassTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);
		//glasssparks(pos, 5 + XORRandom(5));
	}
}

void OnGlassTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("GlassBreak1.ogg", pos, 1.0f, 1.0f);
		//glasssparks(pos, 5 + XORRandom(3));
	}
}

void OnPlasteelTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);
	}
}

void OnPlasteelTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("destroy_stone.ogg", pos, 1.0f, 0.85f);
	}
}

void OnMatterTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("dig_stone.ogg", pos, 0.8f, 1.2f);
		// sparks(pos, 1, 1);
	}
}

void OnMatterTileDestroyed(CMap@ map, u32 index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		//ParticleAnimated("MatterSmoke.png", pos + Vec2f(4, 4), Vec2f(0, -1), 0.0f, 1.0f, 3, 0.0f, false);
		Sound::Play("destroy_gold.ogg", pos, 0.8f, 1.2f);
	}
}

/*void OnBrickTileHit(CMap@ map, u32 index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);
	}
}*/
