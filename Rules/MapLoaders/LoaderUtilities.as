#include "DummyCommon.as";
#include "ParticleSparks.as";
#include "CustomTiles.as";

bool onMapTileCollapse(CMap@ map, u32 offset)
{
	/*if (map.getTile(offset).type > 255)
	{
		CBlob@ blob = getBlobByNetworkID(server_getDummyGridNetworkID(offset));
		if (blob !is null)
		{
			blob.server_Die();
		}
	}*/
	
	return true;
}

TileType server_onTileHit(CMap@ map, f32 damage, u32 index, TileType oldTileType)
{
	if (map.getTile(index).type > 255)
	{
		// print("Hit - Old: " + oldTileType + "; Index: " + index);
		
		switch(oldTileType)
		{
			//IRON
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

			//PLASTEEL
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

			//MATTER
			case CMap::tile_matter:
				return CMap::tile_matter_d0;

			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
				return oldTileType + 1;

			case CMap::tile_matter_f:
				return CMap::tile_empty;

			//GLASS
			case CMap::tile_glass:
				return CMap::tile_glass_f;

			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				return CMap::tile_glass_f;

			case CMap::tile_glass_f:
				return CMap::tile_empty;
				
			//GLASS BACK
			case CMap::tile_glass_back:
				return CMap::tile_glass_back_f;
				
			case CMap::tile_glass_back_v0:
			case CMap::tile_glass_back_v1:
			case CMap::tile_glass_back_v2:
			case CMap::tile_glass_back_v3:
			case CMap::tile_glass_back_v4:
			case CMap::tile_glass_back_v5:
			case CMap::tile_glass_back_v6:
			case CMap::tile_glass_back_v7:
			case CMap::tile_glass_back_v8:
			case CMap::tile_glass_back_v9:
			case CMap::tile_glass_back_v10:
			case CMap::tile_glass_back_v11:
			case CMap::tile_glass_back_v12:
			case CMap::tile_glass_back_v13:
			case CMap::tile_glass_back_v14:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				return CMap::tile_glass_back_f;

			case CMap::tile_glass_back_f:
				return CMap::tile_empty;
		}
	}
	
	return map.getTile(index).type;
}

void onSetTile(CMap@ map, u32 index, TileType tile_new, TileType tile_old)
{
	/*if (isDummyTile(tile_new))
	{
		map.SetTileSupport(index, 10);

		switch(tile_new)
		{
			case Dummy::SOLID:
			case Dummy::OBSTRUCTOR:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				break;
			case Dummy::BACKGROUND:
			case Dummy::OBSTRUCTOR_BACKGROUND:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES);
				break;
			case Dummy::LADDER:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::LADDER | Tile::WATER_PASSES);
				break;
			case Dummy::PLATFORM:
				map.AddTileFlag(index, Tile::PLATFORM);
				break;
		}
	}*/

	if (tile_new == CMap::tile_ground && isClient()) Sound::Play("dig_dirt" + (1 + XORRandom(3)) + ".ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
	
	if (tile_new == CMap::tile_empty || tile_new == CMap::tile_ground_back)
	{
		switch(tile_old)
		{
			case CMap::tile_iron_f:       OnIronTileDestroyed(map, index);        break;
			case CMap::tile_plasteel_f:   OnPlasteelTileDestroyed(map, index);    break;
			case CMap::tile_glass_f:      OnGlassTileDestroyed(map, index);       break;
			case CMap::tile_glass_back_f: OnGlassTileDestroyed(map, index);       break;
			case CMap::tile_matter_f:     OnMatterTileDestroyed(map, index);      break;
		}
	}

	if (map.getTile(index).type > 255)
	{
		map.SetTileSupport(index, 10);
		
		switch(tile_new)
		{
			//IRON
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

			//PLASTEEL
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

			//MATTER
			case CMap::tile_matter:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_matter_d0:
			case CMap::tile_matter_d1:
			case CMap::tile_matter_f:
				OnMatterTileHit(map, index);
				break;

			//GLASS
			case CMap::tile_glass:
				SetTileFaces(map, map.getTileWorldPosition(index), CMap::tile_glass, CMap::tile_glass_v14, directions_all);
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
				
			case CMap::tile_glass_v0:
			case CMap::tile_glass_v1:
			case CMap::tile_glass_v2:
			case CMap::tile_glass_v3:
			case CMap::tile_glass_v4:
			case CMap::tile_glass_v5:
			case CMap::tile_glass_v6:
			case CMap::tile_glass_v7:
			case CMap::tile_glass_v8:
			case CMap::tile_glass_v9:
			case CMap::tile_glass_v10:
			case CMap::tile_glass_v11:
			case CMap::tile_glass_v12:
			case CMap::tile_glass_v13:
			case CMap::tile_glass_v14:
				map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_glass_f:
				UpdateTileFaces(map, map.getTileWorldPosition(index), CMap::tile_glass, CMap::tile_glass_v14, directions_all);
				OnGlassTileHit(map, index);
				break;

			//GLASS BACK
			case CMap::tile_glass_back:
				SetTileFaces(map, map.getTileWorldPosition(index), CMap::tile_glass_back, CMap::tile_glass_back_v14, directions_all);
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;
			
			case CMap::tile_glass_back_v0:
			case CMap::tile_glass_back_v1:
			case CMap::tile_glass_back_v2:
			case CMap::tile_glass_back_v3:
			case CMap::tile_glass_back_v4:
			case CMap::tile_glass_back_v5:
			case CMap::tile_glass_back_v6:
			case CMap::tile_glass_back_v7:
			case CMap::tile_glass_back_v8:
			case CMap::tile_glass_back_v9:
			case CMap::tile_glass_back_v10:
			case CMap::tile_glass_back_v11:
			case CMap::tile_glass_back_v12:
			case CMap::tile_glass_back_v13:
			case CMap::tile_glass_back_v14:
				map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
				if (isClient()) Sound::Play("build_wall.ogg", map.getTileWorldPosition(index), 1.0f, 1.0f);
				break;

			case CMap::tile_glass_back_f:
				UpdateTileFaces(map, map.getTileWorldPosition(index), CMap::tile_glass_back, CMap::tile_glass_back_v14, directions_all);
				OnGlassBackTileHit(map, index);
				break;
		}
	}
}

void OnIronTileHit(CMap@ map, const u32&in index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("dig_stone.ogg", pos, 1.0f, 1.0f);
		sparks(pos, 1, 1);
	}
}

void OnIronTileDestroyed(CMap@ map, const u32&in index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("destroy_stone.ogg", pos, 1.0f, 1.0f);
	}
}



void OnGlassTileHit(CMap@ map, const u32&in index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION | Tile::LIGHT_PASSES);
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);
		GlassSparks(pos, 5 + XORRandom(5));
	}
}

void OnGlassBackTileHit(CMap@ map, const u32&in index)
{
	map.AddTileFlag(index, Tile::BACKGROUND | Tile::LIGHT_PASSES | Tile::WATER_PASSES | Tile::LIGHT_SOURCE);
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("GlassBreak2.ogg", pos, 1.0f, 1.0f);
		GlassSparks(pos, 3 + XORRandom(2));
	}
}

void OnGlassTileDestroyed(CMap@ map, const u32&in index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("GlassBreak1.ogg", pos, 1.0f, 1.0f);
		GlassSparks(pos, 5 + XORRandom(3));
	}
}

void GlassSparks(Vec2f pos, const u8&in amount)
{
	if (!isClient()) return;

	pos += Vec2f(XORRandom(8), XORRandom(8));

	SColor[] glass_colors =
	{
		SColor(255, 217, 242, 246),
		SColor(255, 255, 255, 255),
		SColor(255, 85, 119, 130),
		SColor(255, 79, 145, 167),
		SColor(255, 48, 60, 65),
		SColor(255, 21, 27, 30)
	};

	for (u8 i = 0; i < amount; i++)
	{
		Vec2f vel = getRandomVelocity(0.6f, 2.0f, 180.0f);
		vel.y = -Maths::Abs(vel.y) + Maths::Abs(vel.x) / 4.0f - 2.0f - f32(XORRandom(100)) / 100.0f;
		ParticlePixel(pos, vel, glass_colors[XORRandom(glass_colors.length)], true);
		makeGibParticle("GlassSparks.png", pos, vel, 0, XORRandom(5) - 1, Vec2f(4.0f, 4.0f), 2.0f, 1, "GlassBreak1.ogg");
	}
}

void OnPlasteelTileHit(CMap@ map, const u32&in index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("dig_stone.ogg", pos, 1.0f, 0.7f);
	}
}

void OnPlasteelTileDestroyed(CMap@ map, const u32&in index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("destroy_stone.ogg", pos, 1.0f, 0.85f);
	}
}

void OnMatterTileHit(CMap@ map, const u32&in index)
{
	map.AddTileFlag(index, Tile::SOLID | Tile::COLLISION);
	
	if (isClient())
	{ 
		Vec2f pos = map.getTileWorldPosition(index);
		Sound::Play("dig_stone.ogg", pos, 0.8f, 1.2f);
		// sparks(pos, 1, 1);
	}
}

void OnMatterTileDestroyed(CMap@ map, const u32&in index)
{
	if (isClient())
	{
		Vec2f pos = map.getTileWorldPosition(index);
		//ParticleAnimated("MatterSmoke.png", pos + Vec2f(4, 4), Vec2f(0, -1), 0.0f, 1.0f, 3, 0.0f, false);
		Sound::Play("destroy_gold.ogg", pos, 0.8f, 1.2f);
	}
}

///GENERIC

const Vec2f[] directions_all = { Vec2f(0, -8), Vec2f(0, 8), Vec2f(8, 0), Vec2f(-8, 0) };
const Vec2f[] directions_up_down = { Vec2f(0, -8), Vec2f(0, 8) };

u8 getTileFaces(CMap@ map, Vec2f pos, const u16&in min, const u16&in max, const Vec2f[]@ directions)
{
	u8 mask = 0;
	for (u8 i = 0; i < directions.length; i++)
	{
		const u16 tile = map.getTile(pos + directions[i]).type;
		if (isTileBetween(tile, min, max)) mask |= 1 << i;
	}
	return mask;
}

void SetTileFaces(CMap@ map, Vec2f pos, const u16&in min, const u16&in max, const Vec2f[]@ directions)
{
	map.SetTile(map.getTileOffset(pos), min + getTileFaces(map, pos, min, max, directions));
	UpdateTileFaces(map, pos, min, max, directions);
}

void UpdateTileFaces(CMap@ map, Vec2f pos, const u16&in min, const u16&in max, const Vec2f[]@ directions)
{
	for (u8 i = 0; i < directions.length; i++)
	{
		Vec2f tilepos = pos + directions[i];
		if (isTileBetween(map.getTile(tilepos).type, min, max))
			map.SetTile(map.getTileOffset(tilepos), min + getTileFaces(map, tilepos, min, max, directions));
	}
}
