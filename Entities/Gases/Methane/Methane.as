#include "Hitters.as";
#include "Explosion.as";
#include "ExplosionDelay.as";

void onInit(CBlob@ this)
{
	this.Tag("gas");
	this.Tag("invincible");
	
	this.set_string("gas_material", "mat_methane");

	this.getShape().SetGravityScale(-0.025f);
	
	this.getSprite().setRenderStyle(RenderStyle::additive);
	this.getSprite().SetZ(10.0f);
	
	this.set_f32("map_damage_ratio", 0.2f);
	this.set_f32("map_damage_radius", 64.0f);
	this.set_string("custom_explosion_sound", "methane_explode.ogg");
	this.set_u8("custom_hitter", Hitters::burn);

	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 90;
	
	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());
	
	this.server_SetTimeToDie(90);
}

void onTick(CBlob@ this)
{
	if (this.getPosition().y < 0) this.server_Die();
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case Hitters::fire:
		case Hitters::burn:
		case Hitters::explosion:
		case Hitters::keg:
		case Hitters::mine:
			server_SetBombToExplode(this, 30);
			break;
	}
	
	return 0.0f;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	
	const string name = blob.getName();
	const bool isLightSource = (name == "lantern" || name == "fireplace") && blob.isLight();
	if (isLightSource || name == "infernalstone")
	{
		server_SetBombToExplode(this, 30);
	}
}
 
void onDie(CBlob@ this)
{
	if (this.hasTag("doExplode"))
	{
		DoExplosion(this);
	}
}

void DoExplosion(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	if (isServer())
	{
		CBlob@[] blobs;
		
		if (map.getBlobsInRadius(pos, 32.0f, @blobs))
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
	
		for (int i = 0; i < 24; i++)
		{
			map.server_setFireWorldspace(this.getPosition() + getRandomVelocity(0, 8 + XORRandom(48), 360), true);
		}
	}

	Explode(this, 32.0f, 0.1f);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("gas");
}
