// Gingerbeard re-implemented this system back
// cuz its so useful

namespace CMap
{
	enum CustomTile
	{ 
		tile_iron = 384,
		tile_iron_d0,
		tile_iron_d1,
		tile_iron_d2,
		tile_iron_d3,
		tile_iron_d4,
		tile_iron_d5,
		tile_iron_d6,
		tile_iron_d7,
		tile_iron_f,

		tile_glass = 394,
		tile_glass_f,

		tile_plasteel = 396,
		tile_plasteel_d0,
		tile_plasteel_d1,
		tile_plasteel_d2,
		tile_plasteel_d3,
		tile_plasteel_d4,
		tile_plasteel_d5,
		tile_plasteel_d6,
		tile_plasteel_d7,
		tile_plasteel_d8,
		tile_plasteel_d9,
		tile_plasteel_d10,
		tile_plasteel_d11,
		tile_plasteel_d12,
		tile_plasteel_d13,
		tile_plasteel_f,

		tile_matter = 412,
		tile_matter_d0,
		tile_matter_d1,
		tile_matter_f

		/*tile_brick_v0 = 416,
		tile_brick_v1,
		tile_brick_v2,
		tile_brick_v3,
		tile_brick_d0,
		tile_brick_d1,
		tile_brick_d2,
		tile_brick_d3,
		tile_brick_d4,
		tile_brick_d5,
		tile_brick_f,*/
	};
};

bool isTileIron(const u16&in tile)
{
	return tile >= CMap::tile_iron && tile <= CMap::tile_iron_f;
}

bool isTilePlasteel(const u16&in tile)
{
	return tile >= CMap::tile_plasteel && tile <= CMap::tile_plasteel_f;
}

bool isTileMatter(const u16&in tile) 
{
	return tile >= CMap::tile_matter && tile <= CMap::tile_matter_f;
}

bool isTileGlass(const u16&in tile)
{
	return tile >= CMap::tile_glass && tile <= CMap::tile_glass_f;
}

//universal
bool isTileBetween(const u16&in tile, const u16&in min, const u16&in max)
{
	return tile >= min && tile <= max;
}

//engine replacement since the engine is garbage and cannot be modified script side
bool isTileSolid(CMap@ map, const u16&in tile)
{
	return map.isTileSolid(tile) || isTileIron(tile) || isTilePlasteel(tile) || isTileMatter(tile) || isTileGlass(tile);
}

//tile tiers: mainly used in constructing/repairing tiles to decipher which tiles replace which other tiles
//higher numbers mean that they overwrite lower numbers in building (e.g iron can be placed on stone)

u8 getTileTierSolid(const u16&in tile)
{
	if (isTileBetween(tile, CMap::tile_wood_d1, CMap::tile_wood_d0))         return 0; //damaged wood block
	if (tile == CMap::tile_wood)                                             return 1; //wood

	//if (tile == CMap::tile_glass_f)                                          return 1; //damaged glass
	//if (tile == CMap::tile_glass)                                            return 2; //glass

	if (isTileBetween(tile, CMap::tile_castle_d1, CMap::tile_castle_d0))     return 1; //damaged castle
	if (tile == CMap::tile_castle)                                           return 2; //castle

	if (isTileBetween(tile, CMap::tile_iron_d0, CMap::tile_iron_f))          return 2; //damaged iron
	if (isTileIron(tile))                                                    return 3; //iron

	if (isTileBetween(tile, CMap::tile_plasteel_d0, CMap::tile_plasteel_f))  return 3; //damaged plasteel
	if (isTilePlasteel(tile))                                                return 4; //plasteel
	return 255;
}

u8 getTileTierBackground(const u16&in tile)
{
	if (tile == CMap::tile_wood_back)                                         return 1; //wood
	//if (tile == CMap::tile_bglass)                                            return 2; //glass
	if (tile == CMap::tile_castle_back)                                       return 2; //castle

	//if (isTileBetween(tile, CMap::tile_biron_d0, CMap::tile_biron_f))         return 2; //damaged iron
	//if (isTileBIron(tile))                                                    return 3; //iron

	//if (isTileBetween(tile, CMap::tile_bplasteel_d0, CMap::tile_bplasteel_f)) return 3; //damaged plasteel
	//if (isTileBPlasteel(tile))                                                return 4; //plasteel
	return 0;
}
