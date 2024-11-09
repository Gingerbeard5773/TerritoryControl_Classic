#include "Hitters.as";
#include "Explosion.as";
#include "TC_Translation.as";

const u32 fuel_timer_max = 30 * 0.50f;

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::SmallRocket));
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 32.0f);
	this.set_string("custom_explosion_sound", "Keg.ogg");

	this.set_f32("velocity", 10.0f);
	this.set_u32("fuel_timer", getGameTime() + fuel_timer_max + XORRandom(15));
	
	this.SetMapEdgeFlags(CBlob::map_collide_left | CBlob::map_collide_right);
	//this.sendonlyvisible = false;

	this.getShape().SetRotationsAllowed(true);

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Rocket_Idle.ogg");
	sprite.SetEmitSoundSpeed(2.0f);
	sprite.SetEmitSoundPaused(false);

	this.SetLight(true);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 255, 100, 0));
}

void onTick(CBlob@ this)
{
	if (this.get_u32("fuel_timer") > getGameTime())
	{
		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.15f, 15.0f));

		Vec2f dir = Vec2f(0, 1);
		dir.RotateBy(this.getAngleDegrees());
		
		Random rand(this.getNetworkID() + this.getTickSinceCreated() * 100);
		this.setVelocity(dir * -this.get_f32("velocity") + Vec2f(0, this.getTickSinceCreated() > 5 ? rand.NextRanged(50) / 100.0f : 0));
		MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
	}
	else
	{
		this.getSprite().SetEmitSoundPaused(true);
	}

	this.setAngleDegrees(-this.getVelocity().Angle() + 90);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!isServer()) return;

	if (blob !is null ? !doesCollideWithBlob(this, blob) || (blob.isPlatform() && !solid) : !solid) return;

	this.server_Die();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
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
	this.set_Vec2f("explosion_offset", Vec2f(0, -16).RotateBy(this.getAngleDegrees()));
	
	Random rand(this.getNetworkID());
	
	Explode(this, 32.0f, 3.0f);
	for (u8 i = 0; i < 4; i++)
	{
		Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f, (int(rand.NextRanged(200)) - 100) / 200.0f);
		
		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 16.0f + rand.NextRanged(16), 10.0f, 4, 5.0f, Hitters::explosion);
	}
	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 4).RotateBy(this.getAngleDegrees());
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}
