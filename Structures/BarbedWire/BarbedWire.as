#include "Hitters.as";
#include "StaticToggleCommon.as";

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(true);
	shape.getConsts().mapCollisions = false;

	CSprite@ sprite = this.getSprite();
    sprite.getConsts().accurateLighting = false;  
	sprite.RotateBy(XORRandom(4) * 90, Vec2f(0, 0));
	sprite.SetZ(-50); //background

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().tickFrequency = 240 + XORRandom(60);

	this.server_setTeamNum(-1);
	
	this.Tag("builder always hit");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && blob.hasTag("flesh") && isServer())
	{
		this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.125f, Hitters::spikes, true);
	}
}

const Vec2f[] directions = { Vec2f(0, -8), Vec2f(0, 8), Vec2f(8, 0), Vec2f(-8, 0) };

void onTick(CBlob@ this)
{
	// Fall if this has no support. we have to do it here because this blob has no 'block_support'
	
	if (!isServer() || this.hasTag("fallen")) return;

	CMap@ map = getMap();
	Vec2f position = this.getPosition();
	for (u8 i = 0; i < 4; i++)
	{
		if (map.getTile(position + directions[i]).type != CMap::tile_empty)
			return;
	}
	
	StaticOff(this);
	this.SendCommand(this.getCommandID("static off"));
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	switch (customData)
	{
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= 0.125;
			break;

		case Hitters::bomb:
			dmg *= 0.25f;
			break;

		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 0.25f;
			break;

		case Hitters::bomb_arrow:
			dmg *= 0.25f;
			break;

		case Hitters::cata_stones:
			dmg *= 0.25f;
			break;
			
		case Hitters::builder: // boat ram
			dmg *= 4.0f;
			break;
	}

	if (hitterBlob !is null && hitterBlob !is this && customData == Hitters::builder && isServer())
	{
		this.server_Hit(hitterBlob, worldPoint, Vec2f(0, 0), 0.125f, Hitters::spikes, false);
	}
	
	return dmg;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return false;
}
