#include "Hitters.as";
#include "Explosion.as";
#include "Knocked.as";
#include "TC_Translation.as";
#include "ShockwaveCommon.as";

string[] particles = 
{
	"SmallSteam",
	"MediumSteam",
	"LargeSmoke",
};

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::StunBomb));
	this.getShape().SetRotationsAllowed(true);
	this.maxQuantity = 4;
	
	this.Tag("explosive");
	
	this.set_bool("map_damage_raycast", false);
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
	if (damage >= this.getHealth() && !this.hasTag("doExplode") && isServer())
	{
		this.Tag("doExplode");
		this.Sync("doExplode", true);
		this.server_Die();
	}
	return damage;
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("no pickup") && this.get_u8("bomber team") == blob.getTeamNum()) return false; //do not kill our own bomber's bombs
	
	return blob.isCollidable() && !blob.hasTag("gas");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !doesCollideWithBlob(this, blob) || (blob.isPlatform() && !solid) : !solid) return;

	if (solid) this.Untag("no pickup");
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen >= 6.0f && !this.hasTag("doExplode") && isServer()) 
	{
		this.Tag("doExplode");
		this.Sync("doExplode", true);
		this.server_Die();
	}
}

void DoExplosion(CBlob@ this)
{
	Random rand(this.getNetworkID());
	const int random = rand.NextRanged(16);
	Vec2f pos = this.getPosition();
	const f32 modifier = 1 + Maths::Log(this.getQuantity());
	const f32 angle = -this.getOldVelocity().Angle();
	
	this.set_f32("map_damage_radius", 32.0f + random);
	this.set_f32("map_damage_ratio", 0.01f);
	
	Explode(this, 32.0f + random, 0.2f);
	
	if (isClient())
	{
		const int amount = 200 * modifier * (v_fastrender ? 0.5f : 1.0f);
		for (int i = 0; i < amount; i++) 
		{
			Vec2f dir = getRandomVelocity(angle, 8.5f * (XORRandom(100) * 0.01f), 100);
			MakeParticle(this, dir, particles[XORRandom(particles.length)]);
		}
		
		Shockwave wave(this.getPosition(), 2.5f, 5.00f);
		getRules().push("shockwaves", @wave);
	}

	CMap@ map = getMap();
	CBlob@[] blobs;
	if (map.getBlobsInRadius(pos, 192.0f, @blobs))
	{
		const f32 mod = Maths::Clamp(1.00f - (3 / 192), 0, 1);
		for (int i = 0; i < blobs.length; i++)
		{		
			CBlob@ blob = blobs[i];
			if (blob !is null && !blob.getShape().isStatic() && !map.rayCastSolid(pos, blob.getPosition())) 
			{
				Vec2f dir = blob.getPosition() - pos;
				dir.Normalize();
				
				blob.AddForce(dir * blob.getRadius() * 70 * mod * modifier);
				SetKnocked(blob, 60 * mod);
			}
		}
	}
	
	this.getSprite().Gib();
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	const f32 rad = this.getRadius();
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * rad;
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 1 + XORRandom(2), -0.005f, true);
}
