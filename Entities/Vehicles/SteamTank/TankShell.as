#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(20);
	
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;

	this.Tag("map_damage_dirt");
	
	this.set_f32("map_damage_radius", 64.0f);
	this.set_f32("map_damage_ratio", 0.2f);
	
	this.Tag("projectile");

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	this.sendonlyvisible = false;
	
	CSprite@ sprite = this.getSprite();
	sprite.getConsts().accurateLighting = false;
	sprite.SetEmitSound("Shell_Whistle.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.0f);
}

void onTick(CBlob@ this)
{
	Vec2f velocity = this.getVelocity();
	const f32 angle = velocity.Angle();
	this.setAngleDegrees(-angle);
	
	const f32 modifier = Maths::Max(0, velocity.y * 0.02f);
	this.getSprite().SetEmitSoundVolume(Maths::Max(0, modifier));
	
	if (isServer())
	{
		Vec2f end;
		if (getMap().rayCastSolidNoBlobs(this.getOldPosition(), this.getPosition(), end))
		{
			this.setPosition(end);
			this.server_Die();
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!isServer()) return;

	if (blob is null) return;

	if (blob.isPlatform() && !solid) return;

	if (blob.hasTag("no pickup") && blob.get_u8("bomber team") == this.getTeamNum()) return; //do not kill our own bomber's bombs

	if (doesCollideWithBlob(this, blob))
	{
		this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	const bool willExplode = this.getTeamNum() == blob.getTeamNum() ? blob.getShape().isStatic() : true;
	if (blob.isCollidable() && willExplode)
	{
		CPlayer@ player = blob.getPlayer();
		if (player !is null && player is this.getDamageOwnerPlayer()) return false;

		return true;
	}
	return false;
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");

	Explode(this, 64.0f, 4.0f);
	LinearExplosion(this, this.getOldVelocity(), 16.0f, 16.0f, 2, 1.5f, Hitters::bomb);

	this.getSprite().Gib();
}
