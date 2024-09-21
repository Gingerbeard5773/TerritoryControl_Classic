#include "Hitters.as";
#include "CustomTiles.as";

void onInit(CBlob@ this)
{
	this.maxQuantity = 250;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1, Vec2f point2)
{
	// if (blob !is null && this.getQuantity() > blob.getMass() * 2)
	// {
		// CBlob@ dust = server_CreateBlob("mat_matter", this.getTeamNum(), point1);
		// dust.server_SetQuantity(Maths::Max(0, blob.getMass() * 0.5f));
		
		// blob.server_Die();
	// }
	if (blob is null && isServer())
	{	
		CMap@ map = getMap();
		Vec2f pos = point2 - (normal * 4);
		const u16 type = map.getTile(pos).type;
		if (!map.isTileBedrock(type) && map.isTileSolid(pos) && !isTileMatter(type)) 
		{
			map.server_SetTile(pos, CMap::tile_matter);
			this.server_SetQuantity(Maths::Max(0, int(this.getQuantity()) - 1 - XORRandom(15)));
		}
	}
}