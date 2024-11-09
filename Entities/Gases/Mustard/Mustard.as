#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("gas");
	this.Tag("invincible");

	this.getShape().SetGravityScale(0.10f);
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);

	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 15;
	
	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());
	this.server_SetTimeToDie(90 + XORRandom(30));
}

void onTick(CBlob@ this)
{	
	CBlob@[] blobsInRadius;
	getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 1.5f, @blobsInRadius);

	for (u16 i = 0; i < blobsInRadius.length; i++)
	{
		CBlob@ blob = blobsInRadius[i];
		if (!blob.hasTag("flesh") || blob.hasTag("gas immune") || blob.hasTag("scubagear")) continue;

		if (!blob.exists("mustard value"))
		{
			blob.AddScript("MustardEffect.as");
		}

		const f32 mustard_value = blob.get_f32("mustard value");
		blob.set_f32("mustard value", Maths::Min(mustard_value + 1.0f, 90.0f));
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("gas");
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0.0f;
}
