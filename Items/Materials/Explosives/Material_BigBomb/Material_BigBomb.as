#include "Hitters.as";
#include "Explosion.as";
#include "ExplosionDelay.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::BigBomb));
	this.getShape().SetRotationsAllowed(true);
	this.set_string("custom_explosion_sound", "");
	this.maxQuantity = 1;
	
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
	if (vellen >= 10.0f)
	{
		server_SetBombToExplode(this);
	}
}

void DoExplosion(CBlob@ this)
{
	Sound::Play("KegExplosion", this.getPosition(), 3.0f);
	Explode(this, 64.0f, 30.0f);
	
	Random rand(this.getNetworkID());
	for (u8 i = 0; i < 8; i++)
	{
		Vec2f dir = Vec2f(1 - i / 4.0f, -1 + i / 4.0f);
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f, (int(rand.NextRanged(200)) - 100) / 200.0f);
		
		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 40.0f + rand.NextRanged(64), 60.0f, 6, 20.0f, Hitters::explosion, false, true);
	}
	this.getSprite().Gib();
}
