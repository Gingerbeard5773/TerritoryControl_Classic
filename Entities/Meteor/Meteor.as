#include "Explosion.as";
#include "Hitters.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

const u32 max_heat = 10800;

void onInit(CBlob@ this)
{
	this.set_f32("map_damage_ratio", 0.5f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	this.Tag("map_damage_dirt");
	this.Tag("map_destroy_ground");

	this.Tag("ignore fall");
	this.Tag("medium weight");
	
	this.addCommandID("client_hitground");
	
	this.SetLight(true);
	this.SetLightRadius(15.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.set_s32("heat", max_heat); // 6 min cooldown time (unless in water)

	this.server_setTeamNum(-1);

	if (this.hasTag("explosive"))
	{
		Random rand(this.getNetworkID());
		this.setVelocity(Vec2f(20.0f - int(rand.NextRanged(4001)) / 100.0f, 15.0f));

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSound("Rocket_Idle.ogg");
			sprite.SetEmitSoundPaused(false);
			sprite.SetEmitSoundVolume(2.0f);

			client_AddToChat(Translate::MeteorEvent, SColor(255, 255, 0, 0));
		}
	}
}

void onTick(CBlob@ this)
{
	s32 heat = this.get_s32("heat");
	const f32 heatscale = f32(heat) / f32(max_heat);

	if (isClient() && heat > 0 && getGameTime() % int((1.0f - heatscale) * 9.0f + 1.0f) == 0)
	{
		MakeParticle(this, XORRandom(100) < 10 ? ("SmallSmoke" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
	}

	if (this.hasTag("collided") && this.getVelocity().Length() < 2.0f)
	{
		this.Untag("explosive");
	}

	if (!this.hasTag("explosive"))
	{
		this.getSprite().SetEmitSoundPaused(true);
		if (heat > 0)
		{
			AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
			if (point !is null)
			{
				CBlob@ holder = point.getOccupied();
				if (holder !is null && XORRandom(3) == 0)
				{
					this.server_DetachFrom(holder);
				}
			}

			if (this.isInWater())
			{
				if (isClient() && getGameTime() % 4 == 0)
				{
					MakeParticle(this, "MediumSteam");
					this.getSprite().PlaySound("Steam.ogg");
				}
				heat -= 10;
			}
			else
			{
				heat -= 1;
			}

			if (isServer() && XORRandom(100) < 70)
			{
				CMap@ map = getMap();
				Vec2f pos = this.getPosition();

				CBlob@[] blobs;

				const f32 radius = this.getRadius();
				if (map.getBlobsInRadius(pos, radius * 3.0f, @blobs))
				{
					for (int i = 0; i < blobs.length; i++)
					{
						CBlob@ blob = blobs[i];
						if (blob.isFlammable()) map.server_setFireWorldspace(blob.getPosition(), true);
					}
				}

				const f32 tileDist = radius * 2.0f;
				if (map.getTile(pos).type == CMap::tile_wood_back) map.server_setFireWorldspace(pos, true);
				if (map.getTile(pos + Vec2f(0, tileDist)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(0, tileDist), true);
				if (map.getTile(pos + Vec2f(0, -tileDist)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(0, -tileDist), true);
				if (map.getTile(pos + Vec2f(tileDist, 0)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(tileDist, 0), true);
				if (map.getTile(pos + Vec2f(-tileDist, 0)).type == CMap::tile_wood) map.server_setFireWorldspace(pos + Vec2f(-tileDist, 0), true);
			}

			if (isClient() && XORRandom(100) < 60) this.getSprite().PlaySound("FireRoar.ogg");
		}
		else
		{
			this.SetLight(false);
		}
	}

	if (heat < 0) heat = 0;
	this.set_s32("heat", heat);
}

void MakeParticle(CBlob@ this, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition(), Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (solid)
	{
		onHitGround(this);
	}
}

void onHitGround(CBlob@ this)
{
	if (!this.hasTag("explosive")) return;

	CMap@ map = getMap();

	const f32 vellen = this.getOldVelocity().Length();
	if (vellen < 8.0f) return;

	const f32 power = Maths::Min(vellen / 9.0f, 1.0f);

	const f32 boomRadius = 48.0f * power;
	this.set_f32("map_damage_radius", boomRadius);
	Explode(this, boomRadius, 20.0f);

	if (isServer())
	{
		if (!this.hasTag("collided"))
		{
			this.SendCommand(this.getCommandID("client_hitground"));
			this.Tag("collided");
		}

		const int radius = int(boomRadius / map.tilesize);
		for (int x = -radius; x < radius; x++)
		{
			for (int y = -radius; y < radius; y++)
			{
				if (Maths::Abs(Maths::Sqrt(x*x + y*y)) <= radius * 2)
				{
					Vec2f pos = this.getPosition() + Vec2f(x, y) * map.tilesize;

					if (XORRandom(64) == 0)
					{
						CBlob@ blob = server_CreateBlob("flame", -1, pos);
						blob.server_SetTimeToDie(15 + XORRandom(6));
					}
				}
			}
		}

		CBlob@[] blobs;
		map.getBlobsInRadius(this.getPosition(), boomRadius, @blobs);
		for (int i = 0; i < blobs.length; i++)
		{
			map.server_setFireWorldspace(blobs[i].getPosition(), true);
		}

		this.setVelocity(this.getOldVelocity() / 1.55f);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client_hitground") && isClient())
	{
		this.getSprite().SetEmitSoundPaused(true);
		ShakeScreen(500.0f, 120.0f, this.getPosition());
		SetScreenFlash(150, 255, 238, 218);
		Sound::Play("MeteorStrike.ogg", this.getPosition(), 1.5f, 1.0f);
		this.Tag("collided");
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData != Hitters::builder && customData != Hitters::drill)
    {
        s32 heat = this.get_s32("heat");
        if (customData == Hitters::water || customData == Hitters::water_stun && heat > 0)
        {
            if (isClient())
            {
                MakeParticle(this, "MediumSteam");
                this.getSprite().PlaySound("Steam.ogg");
            }
            heat -= 350;
            if (heat < 0) heat = 0;
            this.set_s32("heat", heat);
        }
        return 0.0f;
    }

	if (isServer())
	{
		Material::createFor(hitterBlob, "mat_stone", 10 + XORRandom(50));
		if (XORRandom(2) == 0) Material::createFor(hitterBlob, "mat_copper", 5 + XORRandom(10));
		if (XORRandom(2) == 0) Material::createFor(hitterBlob, "mat_iron", 10 + XORRandom(40));
		if (XORRandom(2) == 0) Material::createFor(hitterBlob, "mat_mithril", 5 + XORRandom(20));
		if (XORRandom(2) == 0) Material::createFor(hitterBlob, "mat_gold", XORRandom(35));
	}
	return damage;
}
