#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(20);
	
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;
	
	this.Tag("map_damage_dirt");
	
	this.Tag("projectile");
	this.sendonlyvisible = false;

	this.getSprite().getConsts().accurateLighting = false;

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	
	this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);
}

void onTick(CBlob@ this)
{
	Vec2f velocity = this.getVelocity();
	const f32 angle = velocity.Angle();
	this.setAngleDegrees(-angle);
	
	if (isServer())
	{
		Vec2f end;
		if (getMap().rayCastSolidNoBlobs(this.getOldPosition(), this.getPosition(), end))
		{
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
	Vec2f velocity = this.getOldVelocity();

	this.SetMinimapRenderAlways(false);
	
	this.set_f32("map_damage_radius", 512.0f);
	Explode(this, 128.0f, 16.0f);
	
	ShakeScreen(256, 64, this.getPosition());
	SetScreenFlash(64, 255, 255, 255);
	
	Random rand(this.getNetworkID());
	
	for (int i = 0; i < 4; i++)
	{
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f, (int(rand.NextRanged(200)) - 100) / 200.0f);

		LinearExplosion(this, Vec2f(velocity.x * jitter.x, velocity.y * jitter.y), 64.0f + rand.NextRanged(32), 48.0f, 8, 40.0f, Hitters::explosion);
		LinearExplosion(this, velocity, 64, 64.0f, 16, 80.0f, Hitters::explosion);
	}

	this.getSprite().Gib();
}
