#include "Explosion.as";
#include "Hitters.as";
#include "Requirements.as";
#include "StoreCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

// Meteor by Koi_

f32 sound_delay = 0;

void onInit(CBlob@ this)
{
	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 7, Vec2f(16, 16));
	this.SetMinimapRenderAlways(true);
	
	this.getSprite().SetZ(-25); //background

	Shop@ shop;
	if (this.get("shop", @shop))
	{
		shop.button_offset = Vec2f(-6, 0);
	}

	this.set_f32("map_damage_ratio", 1.0f);
	this.set_bool("map_damage_raycast", true);
	this.set_string("custom_explosion_sound", "KegExplosion.ogg");
	this.Tag("map_damage_dirt");
	this.Tag("map_destroy_ground");

	this.Tag("ignore fall");
	this.Tag("high weight");
	this.Tag("scyther inside");
	
	this.inventoryButtonPos = Vec2f(6, 0);

	this.server_setTeamNum(-1);

	if (this.hasTag("explosive"))
	{
		if (isServer())
		{
			if (XORRandom(100) < 75)
			{
				CBlob@ blob = server_CreateBlob("chargerifle", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}

			if (XORRandom(100) < 25)
			{
				CBlob@ blob = server_CreateBlob("chargerifle", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}

			if (XORRandom(100) < 5)
			{
				CBlob@ blob = server_CreateBlob("chargelance", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);

				Material::createFor(this, "mat_lancerod", 50 + XORRandom(50));
			}
			
			if (XORRandom(100) == 0)
			{
				CBlob@ blob = server_CreateBlob("exosuit", this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(blob);
			}

			Material::createFor(this, "mat_lancerod", 50 + XORRandom(50));
			Material::createFor(this, "mat_matter", 50 + XORRandom(200));
			Material::createFor(this, "mat_plasteel", 25 + XORRandom(50));
		}
	
		Random rand(this.getNetworkID());
		this.setVelocity(Vec2f((15 + rand.NextRanged(5)) * (rand.NextRanged(2) == 0 ? 1.00f : -1.00f), 5));

		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSoundVolume(0.5f);
			sprite.SetEmitSound("AncientShip_Loop.ogg");
			sprite.SetEmitSoundPaused(false);
			sprite.RewindEmitSound();

			sprite.ResetTransform();
			sprite.RotateBy(-this.getVelocity().Angle(), Vec2f());

			Sound::Play("AncientShip_Intro.ogg");

			client_AddToChat(Translate::AncientShip, SColor(255, 255, 0, 0));
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return false;
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (isServer() && this.hasTag("scyther inside"))
	{
		server_CreateBlob("scyther", -1, this.getPosition());
		this.Untag("scyther inside");
	}
}

void MakeParticle(CBlob@ this, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition(), Vec2f(), float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onTick(CBlob@ this)
{
	if (this.getOldVelocity().Length() - this.getVelocity().Length() > 8.0f)
	{
		onHitGround(this);
	}

	if (this.hasTag("collided") && this.getVelocity().Length() < 2.0f)
	{
		this.Untag("explosive");
	}

	if (isClient() && this.getTickSinceCreated() < 60) MakeParticle(this, XORRandom(100) < 10 ? "LargeSmoke.png" : "Explosion.png");

	if (this.hasTag("collided"))
	{
		this.getShape().SetGravityScale(1.0f);
		if (!this.hasTag("sound_played") && getGameTime() > (sound_delay * getTicksASecond()))
		{
			this.Tag("sound_played");

			f32 modifier = 1.00f - (sound_delay / 3.0f);
			//print("modifier: " + modifier);

			if (modifier > 0.01f && isClient())
			{
				Sound::Play("Nuke_Kaboom.ogg", getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos()), 1.0f - (0.7f * (1 - modifier)), modifier);
			}

			this.getCurrentScript().tickFrequency = 30;
		}
	}
}

void onHitGround(CBlob@ this)
{
	if (!this.hasTag("explosive")) return;

	CMap@ map = getMap();

	f32 vellen = this.getOldVelocity().Length();
	if (vellen < 8.0f) return;

	f32 power = Maths::Min(vellen * 50.0f, 1.0f);

	if (!this.hasTag("collided"))
	{
		if (isClient())
		{
			ShakeScreen(power * 400.0f, power * 100.0f, this.getPosition());
			SetScreenFlash(100, 255, 255, 255);

			Vec2f pos = getDriver().getWorldPosFromScreenPos(getDriver().getScreenCenterPos());
			sound_delay = (Maths::Abs(this.getPosition().x - pos.x) / 8) / (340 * 0.4f);
		}

		this.Tag("collided");
	}

	f32 boomRadius = 48.0f * power;
	this.set_f32("map_damage_radius", boomRadius);
	Explode(this, boomRadius, 20.0f);

	if (isServer())
	{
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

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (customData != Hitters::builder && customData != Hitters::drill)
		return 0.0f;

	if (isServer())
	{	
		if (XORRandom(2) == 0) Material::createFor(hitterBlob, "mat_steelingot", (XORRandom(2)));
		if (XORRandom(2) == 0) Material::createFor(hitterBlob, "mat_ironingot", (XORRandom(3)));
		if (XORRandom(2) == 0) Material::createFor(hitterBlob, "mat_plasteel", (XORRandom(5)));

		if (XORRandom(100) < 70)
		{
			CBlob@ blob = server_CreateBlob("mat_matter", -1, this.getPosition());
			blob.server_SetQuantity(5);
			blob.setVelocity(Vec2f(100 - XORRandom(200), 100 - XORRandom(200)) / 25.0f);
		}
	}
	
	return damage;
}
