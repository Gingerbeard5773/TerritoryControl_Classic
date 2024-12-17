#include "Hitters.as";
#include "Explosion.as";
#include "FireParticle.as"
#include "FireCommon.as";
#include "ExplosionDelay.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::IncendiaryBomb));
	this.getShape().SetRotationsAllowed(true);
	this.maxQuantity = 2;
	this.set_string("custom_explosion_sound", "KegExplosion");
	
	this.Tag("explosive");
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
	
	return blob.isCollidable() && !blob.hasTag("gas");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !doesCollideWithBlob(this, blob) || (blob.isPlatform() && !solid) : !solid) return;

	if (solid) this.Untag("no pickup");
	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 8.0f)
	{
		server_SetBombToExplode(this);
	}
}

void DoExplosion(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	if (isServer())
	{
		CBlob@[] blobs;		
		if (map.getBlobsInRadius(pos, 128.0f, @blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{		
				CBlob@ blob = blobs[i];
				if (blob !is null && (blob.hasTag("flesh") || blob.hasTag("scenary"))) 
				{
					map.server_setFireWorldspace(blob.getPosition(), true);
					blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.5f, Hitters::fire);
				}
			}
		}
	
		for (u8 i = 0; i < 10 + XORRandom(5) ; i++)
		{
			CBlob@ blob = server_CreateBlob("flame", -1, this.getPosition());
			blob.setVelocity(Vec2f(XORRandom(20) - 10, -XORRandom(10)));
			blob.server_SetTimeToDie(10 + XORRandom(10));
		}
		
		for (u8 i = 0; i < 64; i++)
		{
			map.server_setFireWorldspace(pos + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)) * 8, true);
		}
	}

	ParticleAnimated("Entities/Effects/Sprites/FireFlash.png", this.getPosition(), Vec2f(0, 0.5f), 0.0f, 1.0f, 2, 0.0f, true);

	Random rand(this.getNetworkID());
	Explode(this, 64.0f, 10.0f);
	for (u8 i = 0; i < 4; i++)
	{
		Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f, (int(rand.NextRanged(200)) - 100) / 200.0f);
		
		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 32.0f + rand.NextRanged(32), 15.0f, 6, 8.0f, Hitters::explosion, false, true);
	}
	this.getSprite().Gib();
}
