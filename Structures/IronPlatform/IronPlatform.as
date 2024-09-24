#include "Hitters.as"
#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.SetFacingLeft(XORRandom(128) > 64);

	this.getSprite().getConsts().accurateLighting = true;
	this.getShape().getConsts().waterPasses = false;

	CShape@ shape = this.getShape();
	shape.AddPlatformDirection(Vec2f(0, -1), 89, false);
	shape.SetRotationsAllowed(false);
	
	this.server_setTeamNum(-1); //allow anyone to break them

	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("blocks sword");
	this.Tag("iron_hardness");
}

void onSetStatic(CBlob@ this, const bool isStatic)
{
	if (!isStatic) return;
	
	CMap@ map = getMap();
	Vec2f offset = Vec2f(map.tilesize, map.tilesize) * 0.5f;
	Vec2f topLeft = this.getPosition() - offset;
	Vec2f bottomRight = this.getPosition() + offset;
	map.server_AddSector(topLeft, bottomRight, "no explode", "", this.getNetworkID());

	//this.getSprite().PlaySound("/build_wall.ogg");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::explosion:
			damage *= 0.2f;
			break;
	}
	return damage;
}
