//trap block script for devious builders

#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getSprite().getConsts().accurateLighting = true;
	this.Tag("builder always hit");

	//block knight sword
	this.Tag("blocks sword");

	this.Tag("blocks water");

	this.getShape().SetOffset(Vec2f(-1.25f, 1.25f));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	switch(customData)
	{
		case Hitters::builder:
			dmg *= 2.5f;
			break;
	}
	return dmg;
}
