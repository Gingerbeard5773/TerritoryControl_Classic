//Gingerbeard @ Sept 20, 2024
// Faction building Common

#include "CustomTiles.as";

void server_SetFloor(CBlob@ this, const u16&in tile_type)
{
	if (!isServer()) return;

	CMap@ map = getMap();
	Vec2f offset = this.getPosition() - Vec2f(this.getWidth() * 0.5f, -this.getHeight() + map.tilesize);
	const u8 tilewidth = this.getWidth() / map.tilesize;
	for (u8 i = 0; i < tilewidth; i++)
	{
		Vec2f tilepos = offset + Vec2f(i * map.tilesize, 0);
		Tile tile = map.getTile(tilepos);
		if (!map.isTileSolid(tile) || getTileTierSolid(tile.type) < getTileTierSolid(tile_type))
		{
			map.server_SetTile(tilepos, tile_type);
		}
	}
	offset.y -= map.tilesize * 0.5f;
	map.server_AddSector(offset, offset + Vec2f(this.getWidth(), map.tilesize), "no explode", "", this.getNetworkID());
}
