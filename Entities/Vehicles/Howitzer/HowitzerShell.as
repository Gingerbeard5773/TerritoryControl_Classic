#include "Hitters.as";
#include "Explosion.as";

void onInit(CBlob@ this)
{
	this.server_SetTimeToDie(20);
	
	this.getShape().getConsts().mapCollisions = false;
	this.getShape().getConsts().bullet = true;
	this.getShape().getConsts().net_threshold_multiplier = 4.0f;
	
	this.Tag("projectile");

	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	this.sendonlyvisible = false;
	
	//CPlayer@ local = getLocalPlayer();
	//if (local !is null && (local.getTeamNum() == this.getTeamNum() || local is this.getDamageOwnerPlayer()))
	{
		this.SetMinimapOutsideBehaviour(CBlob::minimap_arrow);
		this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 1, Vec2f(16, 16));
		this.SetMinimapRenderAlways(true);
	}
	
	CSprite@ sprite = this.getSprite();
	sprite.getConsts().accurateLighting = false;
	sprite.SetEmitSound("Shell_Whistle.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.0f);
	sprite.SetEmitSoundSpeed(0.9f);
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
		Vec2f hitpos;
		CMap@ map = getMap();
		if (map.rayCastSolidNoBlobs(this.getOldPosition(), this.getPosition(), hitpos))
		{
			setPositionToLastOpenArea(this, hitpos, map);
			this.server_Die();
		}
	}
}

void setPositionToLastOpenArea(CBlob@ this, Vec2f hitpos, CMap@ map)
{
	//ensure we are exploding in an open area for maximum effect
	Vec2f original = hitpos;
	Vec2f dir = this.getOldVelocity();
	dir.Normalize();
	dir *= map.tilesize;

	for (u8 i = 0; i < 4; i++)
	{
		hitpos -= dir;
		if (!map.isTileSolid(hitpos)) break;
	}

	this.setPosition(hitpos);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!isServer()) return;

	if (blob is null) return;

	if (blob.isPlatform() && !solid) return;

	if (doesCollideWithBlob(this, blob))
	{
		this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	const string name = blob.getName();
	if (name == "log" || blob.exists("eat sound") || blob.hasTag("gas")) return false;

	if (blob.hasTag("material") && !blob.hasTag("explosive")) return false;

	const bool willExplode = this.getTeamNum() == blob.getTeamNum() ? blob.getShape().isStatic() : true; 
	if (blob.isCollidable() && willExplode)
	{
		if (blob.hasTag("no pickup") && blob.get_u8("bomber team") == this.getTeamNum()) return false; //do not kill our own bomber's bombs

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
	this.SetMinimapRenderAlways(false);
	
	Vec2f velocity = this.getOldVelocity();

	Random rand(this.getNetworkID());
	Explode(this, 64.0f, 4.0f);
	for (int i = 0; i < 4; i++)
	{
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f, (int(rand.NextRanged(200)) - 100) / 200.0f);
		LinearExplosion(this, Vec2f(velocity.x * jitter.x, velocity.y * jitter.y), 32.0f + rand.NextRanged(32), 24.0f, 4, 10.0f, Hitters::explosion, false, true);
	}

	this.getSprite().Gib();
}
