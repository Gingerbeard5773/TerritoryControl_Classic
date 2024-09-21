#include "Hitters.as";
#include "Explosion.as";
#include "MakeDustParticle.as";
#include "FireParticle.as";

void onInit(CBlob@ this)
{
	this.getShape().SetStatic(true);
	
	this.Tag("map_damage_dirt");
	this.set_f32("map_damage_radius", 16);
	// this.set_f32("map_damage_ratio", 0.25f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "");
	
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("FireWave_EarRape.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(1.5f);
	
	this.getCurrentScript().tickFrequency = 5;
}

void onTick(CBlob@ this)
{
	CMap@ map = getMap();

	Vec2f top = Vec2f(this.getPosition().x, 0);
	Vec2f bottom = Vec2f(this.getPosition().x, map.tilemapheight * 8);
	Vec2f pos;

	if (map.rayCastSolid(top, bottom, pos))
	{
		if (isServer())
		{
			Explode(this, 32.0f, 1.0f);
		
			if (XORRandom(100) < 75)
			{
				CBlob@ flame = server_CreateBlob("flame", this.getTeamNum(), pos);
				flame.server_SetTimeToDie(3 + XORRandom(10));
			}
		}
	}
	
	if (isServer())
	{
		if (top.x > (map.tilemapwidth * 8) - 8) this.server_Die();
	
		CBlob@[] blobs;
		if (map.getBlobsInBox(Vec2f(top.x - 64, top.y), Vec2f(pos.x, pos.y), blobs))
		{
			for (int i = 0; i < blobs.length; i++)
			{
				CBlob@ blob = blobs[i];
				if (blob is null) continue;
				
				this.server_Hit(blob, blob.getPosition(), Vec2f(), 80.00f, Hitters::fire, true);
			}
		}
	}
	
	for (int i = 0; i < pos.y; i += 8)
	{
		Vec2f p = Vec2f(pos.x + 10 - XORRandom(20), i);
	
		if (isServer() && i % 16 == 0) 
		{
			if (map.isTileWood(map.getTile(p).type)) map.server_setFireWorldspace(p, true);
		}
		if (isClient()) makeSteamParticle(this, p, Vec2f(), XORRandom(100) < 30 ? ("LargeSmoke" + (1 + XORRandom(2))) : "Explosion" + (1 + XORRandom(3)));
	}
	
	if (isClient()) ShakeScreen(256, 64, pos);
	
	this.setPosition(pos + Vec2f(6, 0));
}

void makeSteamParticle(CBlob@ this, Vec2f pos, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * this.getRadius();
	ParticleAnimated(CFileMatcher(filename).getFirst(), pos + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}
