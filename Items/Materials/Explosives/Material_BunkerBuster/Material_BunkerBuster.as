#include "Hitters.as";
#include "Explosion.as";
#include "ExplosionDelay.as";
#include "TC_Translation.as";

string[] particles = 
{
	"LargeSmoke",
	"Explosion.png"
};

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::BunkerBuster));
	this.getShape().SetRotationsAllowed(true);
	this.maxQuantity = 1;
	
	this.Tag("explosive");
	
	this.set_bool("map_damage_raycast", true);
	this.Tag("map_damage_dirt");
}

void onDie(CBlob@ this)
{
	if (this.hasTag("doExplode"))
	{
		DoExplosion(this);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage >= this.getHealth())
	{
		server_SetBombToExplode(this);
		return 0.0f;
	}
	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("no pickup") && this.get_u8("bomber team") == blob.getTeamNum()) return false; //do not kill our own bomber's bombs
	
	return blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !doesCollideWithBlob(this, blob) || (blob.isPlatform() && !solid) : !solid) return;

	if (solid) this.Untag("no pickup");
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 8.0f) 
	{
		server_SetBombToExplode(this);
	}
}

void DoExplosion(CBlob@ this)
{
	Random rand(this.getNetworkID());
	const int random = rand.NextRanged(16);
	const f32 modifier = 1 + Maths::Log(this.getQuantity());
	const f32 vellen = this.getOldVelocity().Length();
	const f32 angle = -this.getOldVelocity().Angle() + 180;

	this.set_f32("map_damage_radius", (40.0f + random) * modifier);
	this.set_f32("map_damage_ratio", 0.25f);
	
	Explode(this, 40.0f + random, 15.0f);
	
	for (int i = 0; i < 8 * modifier; i++) 
	{
		Vec2f dir = getRandomVelocity(angle, 1, 25);
		LinearExplosion(this, dir, (4.0f + XORRandom(4) + (modifier * 8)) * vellen, 8 + XORRandom(8), 10 + XORRandom(vellen * 2), 10.0f, Hitters::explosion);
	}
	
	if (isClient())
	{
		Vec2f pos = this.getPosition();
		for (u8 i = 0; i < 35; i++)
		{
			MakeParticle(this, Vec2f(XORRandom(32) - 16, XORRandom(80) - 60), getRandomVelocity(-angle, XORRandom(500) * 0.01f, 25), particles[XORRandom(particles.length)]);
		}
	}
	
	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + pos, vel, float(XORRandom(360)), 0.5f + XORRandom(100) * 0.01f, 1 + XORRandom(4), XORRandom(100) * -0.00005f, true);
}
