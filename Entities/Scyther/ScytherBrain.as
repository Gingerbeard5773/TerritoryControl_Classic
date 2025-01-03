// Scyther brain

#include "BrainCommon.as"
#include "Hitters.as";
#include "Explosion.as";
#include "GunCommon.as";
#include "TC_Translation.as";

void onInit(CBrain@ this)
{
	if (isServer())
	{
		InitBrain(this);
		this.server_SetActive(true); // always running
		this.getCurrentScript().tickFrequency = 30;
	}
}

void onInit(CBlob@ this)
{
	this.set_f32("gib health", 0.0f);

	this.set_u32("next sound", 0.0f);
	this.set_f32("map_damage_ratio", 0.5f);

	this.Tag("infinite ammunition");

	this.SetLight(true);
	this.SetLightRadius(32.0f);
	this.SetLightColor(SColor(255, 255, 20, 0));

	if (isClient())
	{
		Sound::Play("scyther-intro.ogg");

		client_AddToChat(Translate::ScytherEvent, SColor(255, 255, 0, 0));
	}

	if (isServer() && !this.hasTag("no_weapon"))
	{
		for (u8 i = 0; i < 2; i++)
		{
			CBlob@ ammo = server_CreateBlob("mat_lancerod", this.getTeamNum(), this.getPosition());
			this.server_PutInInventory(ammo);
		}
		
		CBlob@ lance = server_CreateBlob("chargelance", this.getTeamNum(), this.getPosition());
		this.server_Pickup(lance);
	}
}

void onTick(CBlob@ this)
{
	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound"))
		{
			this.getSprite().PlaySound("/scyther-laugh" + XORRandom(2) + ".ogg");
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
}

void onTick(CBrain@ this)
{
	if (!isServer()) return;

	CBlob@ blob = this.getBlob();
	if (blob.getPlayer() !is null)
	{
		this.getCurrentScript().tickFrequency = -1; //turn off
		return;
	}
	
	SearchTarget(this, false, true);

	CBlob@ target = this.getTarget();
	if (target !is null)
	{			
		this.getCurrentScript().tickFrequency = 1;

		const f32 distance = (target.getPosition() - blob.getPosition()).getLength();
		f32 visibleDistance;
		const bool visibleTarget = isVisible(blob, target, visibleDistance);
		
		if (target.hasTag("dead") || distance > 350.0f) 
		{
			blob.setKeyPressed(key_action1, false);
			this.SetTarget(null);
			return;
		}
		else if (visibleTarget && visibleDistance < 80.0f) 
		{
			DefaultRetreatBlob(blob, target);
		}	
		else
		{
			DefaultChaseBlob(blob, target);
		}

		if (distance < 300.0f && blob.getCarriedBlob() !is null)
		{
			Vec2f randomness = Vec2f((100 - XORRandom(200)) * 0.1f, (100 - XORRandom(200)) * 0.1f);
			blob.setAimPos(target.getPosition() + randomness);
			blob.setKeyPressed(key_action1, true);
		}
		
		LoseTarget(this, target);
	}
	else
	{
		blob.setKeyPressed(key_action1, false);
		this.getCurrentScript().tickFrequency = 30;
		RandomTurn(blob);
	}

	FloatInWater(blob); 
} 

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("/scyther-screech" + XORRandom(7) + ".ogg");
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
	
	if (isServer())
	{
		if (hitterBlob !is null && hitterBlob.getTeamNum() != this.getTeamNum())
		{
			this.getBrain().SetTarget(hitterBlob);
		}
	}
	
	return damage;
}

void onDie(CBlob@ this)
{
	DoExplosion(this);
	
	if (isServer())
	{
		for (u8 i = 0; i < 4; i++)
		{
			CBlob@ gib = server_CreateBlob("scythergib", this.getTeamNum(), this.getPosition());
			gib.setVelocity(Vec2f((800 - XORRandom(1600)) / 100.0f, -XORRandom(800) / 100.0f) * 2.0f);
			
			gib.set_u8("frame", i);
		}
		
		for (u8 i = 0; i < 10; i++)
		{
			CBlob@ flame = server_CreateBlob("flame", this.getTeamNum(), this.getPosition());
			flame.setVelocity(Vec2f((800 - XORRandom(1600)) / 100.0f, -XORRandom(800) / 100.0f) * 2.0f);
			flame.server_SetTimeToDie(3 + XORRandom(10));
		}
		
		for (u8 i = 0; i < 8; i++)
		{
			CBlob@ plasteel = server_CreateBlob("mat_plasteel", this.getTeamNum(), this.getPosition());
			plasteel.server_SetQuantity(2 + XORRandom(10));
			plasteel.setVelocity(Vec2f((800 - XORRandom(1600)) / 100.0f, -XORRandom(800) / 100.0f) * 2.0f);
		}
	}
}

void DoExplosion(CBlob@ this)
{
	if (this.hasTag("dead")) return;
	this.Tag("dead");
	
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	if (isServer())
	{
		CBlob@[] blobs;
		map.getBlobsInRadius(pos, 128.0f, @blobs);

		for (u16 i = 0; i < blobs.length; i++)
		{		
			CBlob@ blob = blobs[i];
			if (blob !is null && (blob.hasTag("flesh") || blob.hasTag("scenary"))) 
			{
				map.server_setFireWorldspace(blob.getPosition(), true);
				blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.5f, Hitters::fire);
			}
		}
	}
	
	for (u8 i = 0; i < 64; i++)
	{
		if (isServer()) map.server_setFireWorldspace(pos + Vec2f(8 - XORRandom(16), 8 - XORRandom(16)) * 8, true);
		ParticleAnimated("Entities/Effects/Sprites/FireFlash.png", this.getPosition() + Vec2f(0, -4), Vec2f(0, 0.5f), 0.0f, 1.0f, 2, 0.0f, true);
	}
	
	Explode(this, 400.0f, 8.0f);
	
	Random rand(this.getNetworkID());
	
	for (u8 i = 0; i < 4; i++)
	{
		Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f, (int(rand.NextRanged(200)) - 100) / 200.0f);
		
		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 32.0f + rand.NextRanged(32), 15.0f, 6, 8.0f, Hitters::explosion);
	}
}
