
#include "CustomTiles.as";
#include "MaterialCommon.as";

// Server-side: Create material from a tile
void MaterialsFromTile(CBlob@ this, const u16 &in type, const f32 &in damage, Vec2f worldPoint = Vec2f_zero)
{
	if (damage <= 0.0f) return;

	CMap@ map = getMap();
	const f32 depth = 1 - ((worldPoint.y / 8) / map.tilemapheight);

	if (map.isTileStone(type))
	{
		if (map.isTileThickStone(type))
		{
			Material::createFor(this, "mat_stone", (10 + XORRandom(5)));
			
			if (depth < 0.90f && XORRandom(100) < 70) Material::createFor(this, "mat_copper", (1 + XORRandom(10 * (1 - depth))));
			if (depth < 0.60f && XORRandom(100) < 60) Material::createFor(this, "mat_iron", (5 + XORRandom(8)));
			if (depth < 0.10f && XORRandom(100) < 10) Material::createFor(this, "mat_mithril", (2 + XORRandom(6)));
		} 
		else 
		{
			Material::createFor(this, "mat_stone", (4 + XORRandom(4)));
			if (depth > 0.40f && depth < 0.80f && XORRandom(100) < 50) Material::createFor(this, "mat_copper", (2 + XORRandom(4 * (1 - depth))));
			if (depth < 0.60f && XORRandom(100) < 30) Material::createFor(this, "mat_iron", (3 + XORRandom(6)));
		}

		if (XORRandom(80) == 0 && (type == CMap::tile_stone_d0 || type == CMap::tile_stone_d0 - 1)) 
		{
			CBlob@[] blobs;
			getBlobsByName("methanefissure", @blobs);

			if (blobs.length < 8)
			{
				map.server_DestroyTile(worldPoint, 200, this);
				server_CreateBlob("methanefissure", -1, worldPoint);
			}
		}
	}
	else if (map.isTileGold(type))
	{
		Material::createFor(this, "mat_gold", (2 + XORRandom(4)));
		
		if (depth < 0.10f && XORRandom(100) < 35) Material::createFor(this, "mat_mithril", (3 + XORRandom(8)) * (1.2f - depth));
	}
	else if (map.isTileGround(type))
	{
		Material::createFor(this, "mat_dirt", 1 + XORRandom(2));
		if (depth < 0.80f && XORRandom(100) < 10) Material::createFor(this, "mat_copper", (1 + XORRandom(2)));
		if (depth < 0.35f && XORRandom(100) < 60 * (1 - depth)) Material::createFor(this, "mat_sulphur", (1 + XORRandom(5)) * (1.3f - depth));
	}
	else if (map.isTileCastle(type))
	{
		Material::createFor(this, "mat_stone", 1);
	}
	else if (map.isTileWood(type))
	{
		Material::createFor(this, "mat_wood", 1);
	}
	else if (isTileMatter(type))
	{
		Material::createFor(this, "mat_matter", (1 + XORRandom(10)));
	}
}
