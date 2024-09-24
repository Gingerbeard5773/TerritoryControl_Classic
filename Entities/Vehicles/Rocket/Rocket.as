#include "Hitters.as";
#include "Explosion.as";

const u32 fuel_timer_max = 30 * 6;

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");

	this.addCommandID("server_offblast");
	this.addCommandID("client_offblast");
	
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_f32("map_damage_radius", 48.0f);
	this.set_string("custom_explosion_sound", "Keg.ogg");
	this.set_bool("explosive_teamkill", true);
	
	this.set_u32("no_explosion_timer", 0);
	this.set_u32("fuel_timer", 0);
	this.set_f32("velocity", 0.3f);
	
	this.getShape().SetRotationsAllowed(true);
	//this.getShape().getConsts().net_threshold_multiplier = 0.5f;
}

void onTick(CBlob@ this)
{
	if (!this.hasTag("offblast")) return;

	if (this.get_u32("fuel_timer") > getGameTime())
	{
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PILOT");
		if (point is null) return;
	
		CBlob@ holder = point.getOccupied();
		this.set_f32("velocity", Maths::Min(this.get_f32("velocity") + 0.1f, 15.0f));

		Vec2f dir;

		if (holder is null)
		{
			dir = Vec2f(0, 1);
			dir.RotateBy(this.getAngleDegrees());
		}
		else
		{
			dir = holder.getPosition() - holder.getAimPos();
			dir.Normalize();

			f32 mouseAngle = dir.getAngleDegrees();
			if (!holder.isFacingLeft()) mouseAngle += 180;

			this.setAngleDegrees(-this.getVelocity().Angle() + 90);
		}

		this.setVelocity(dir * -this.get_f32("velocity"));
		MakeParticle(this, -dir, XORRandom(100) < 30 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
	}
	else
	{
		this.setAngleDegrees(-this.getVelocity().Angle() + 90);
		this.getSprite().SetEmitSoundPaused(true);
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(0, 16).RotateBy(this.getAngleDegrees());
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void DoExplosion(CBlob@ this)
{
	this.set_Vec2f("explosion_offset", Vec2f(0, -16).RotateBy(this.getAngleDegrees()));
	
	Random rand(this.getNetworkID());
	
	Explode(this, 64.0f, 10.0f);
	for (u8 i = 0; i < 4; i++)
	{
		Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f, (int(rand.NextRanged(200)) - 100) / 200.0f);
		
		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 32.0f + rand.NextRanged(32), 25.0f, 6, 8.0f, Hitters::explosion, false, true);
	}
	this.getSprite().Gib();
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!isServer()) return;

	if (blob !is null ? !blob.isCollidable() || (blob.isPlatform() && !solid) : !solid) return;
	
	if (this.hasTag("offblast") && this.get_u32("no_explosion_timer") < getGameTime())
	{
		this.server_Die();
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!this.isAttached() && !this.hasTag("offblast"))
	{
		caller.CreateGenericButton(11, Vec2f(0.0f, 0.0f), this, this.getCommandID("server_offblast"), "Off blast!");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server_offblast") && isServer())
	{
		if (this.hasTag("offblast")) return;

		if (this.isAttached()) return;

		this.Tag("aerial");
		this.Tag("offblast");
		this.set_u32("no_explosion_timer", getGameTime() + 30);
		this.set_u32("fuel_timer", getGameTime() + fuel_timer_max);
		
		CBitStream stream;
		stream.write_u32(getGameTime());
		this.SendCommand(this.getCommandID("client_offblast"), stream);
	}
	else if (cmd == this.getCommandID("client_offblast") && isClient())
	{
		const u32 gametime = params.read_u32();
		this.Tag("aerial");
		this.Tag("offblast");
		this.set_u32("no_explosion_timer", gametime + 30);
		this.set_u32("fuel_timer", gametime + fuel_timer_max);

		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("Rocket_Idle.ogg");
		sprite.SetEmitSoundSpeed(1.9f);
		sprite.SetEmitSoundPaused(false);

		this.SetLight(true);
		this.SetLightRadius(128.0f);
		this.SetLightColor(SColor(255, 255, 100, 0));
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasAttached();
}
