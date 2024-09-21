#include "Hitters.as";

const f32 maxDistance = 48.0f;

void onInit(CBlob@ this)
{
	this.Tag("medium weight");

	// this.getShape().getVars().waterDragScale = 16.0f;

	this.Tag("ignore fall");
	
	CSprite@ sprite = this.getSprite();
	
	sprite.RemoveSpriteLayer("chain");
	CSpriteLayer@ chain = sprite.addSpriteLayer("chain", "SlaveBall_Chain.png", 32, 2, this.getTeamNum(), 0);

	if (chain !is null)
	{
		Animation@ anim = chain.addAnimation("default", 0, false);
		anim.AddFrame(0);
		chain.SetRelativeZ(-10.0f);
		chain.SetVisible(false);
	}
}

void onTick(CBlob@ this)
{
	CBlob@ slave = getBlobByNetworkID(this.get_u16("slave_id"));
	if (slave !is null)
	{
		Vec2f position = this.getPosition();
		Vec2f dir = (position - slave.getPosition());
		f32 distance = dir.Length();
		dir.Normalize();
		
		if (distance > maxDistance) 
		{
			slave.setPosition(position - dir * maxDistance * 0.999f); 
			if (slave.getPosition().y > position.y)
			{
				if ((position - this.getOldPosition()).Length() < 0.2f)
				{
					slave.AddForce(dir * (distance / maxDistance) * 100);
				}
				else
				{
					const f32 y = Maths::Clamp(slave.getVelocity().y, -5, 5);
					slave.setVelocity(Vec2f(slave.getVelocity().x, y));
				}
			}
		}
		
		if (isClient()) DrawLine(this.getSprite(), this.getPosition(), distance / 32, -dir.Angle(), true);
	}
	else if (isServer())
	{
		this.server_Die();
	}
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getConfig() != "slave";
}

void DrawLine(CSprite@ this, Vec2f startPos, f32 length, f32 angle, bool flip)
{
	CSpriteLayer@ chain = this.getSpriteLayer("chain");
	chain.SetVisible(true);
	chain.ResetTransform();
	chain.ScaleBy(Vec2f(length, 1.0f));
	chain.TranslateBy(Vec2f(length * 16.0f, 0.0f));
	chain.RotateBy(angle + (flip ? 180 : 0), Vec2f());
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::builder:
			damage *= 0.2f;
			break;
	}

	return damage;
}
