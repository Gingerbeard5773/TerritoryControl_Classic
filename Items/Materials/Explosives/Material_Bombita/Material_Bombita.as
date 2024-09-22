#include "Hitters.as";
#include "Explosion.as";

const u8 boom_max = 8;

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(true);
	this.set_u8("boom_count", 0);

	this.Tag("invincible");
	this.Tag("explosive");
	
	this.set_f32("map_damage_ratio", 0.5f);
	// this.set_f32("map_damage_radius", 128.0f);
	// this.set_string("custom_explosion_sound", "Bomb.ogg");
	// this.set_bool("map_damage_raycast", false);
	
	this.getCurrentScript().tickFrequency = 4;
	
	this.maxQuantity = 1;
}

void DoExplosion(CBlob@ this)
{
	ShakeScreen(256, 64, this.getPosition());
	const f32 modifier = this.get_u8("boom_count") / 3.0f;
	
	this.set_f32("map_damage_radius", 20.0f * this.get_u8("boom_count"));
	
	for (u8 i = 0; i < 4; i++)
	{
		Explode(this, 128.0f * modifier, 8.0f);
	}
}

void onTick(CBlob@ this)
{
	if (this.hasTag("doExplode") && this.get_u8("boom_count") < boom_max)
	{
		DoExplosion(this);
		this.set_u8("boom_count", this.get_u8("boom_count") + 1);
		
		if (this.get_u8("boom_count") >= boom_max)
		{
			this.server_Die();
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (damage >= this.getHealth())
	{
		this.Tag("doExplode");
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
	if (vellen > 5.0f)
	{
		this.Tag("doExplode");
	}
}
