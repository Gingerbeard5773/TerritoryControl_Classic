#include "AnimalConsts.as";
#include "Explosion.as";

const u8 DEFAULT_PERSONALITY = AGGRO_BIT;

void onInit(CBlob@ this)
{
	//for EatOthers
	string[] tags = {"player"};
	this.set("tags to eat", tags);

	this.set_f32("bite damage", 0.05f);

	//brain
	this.set_u8(personality_property, DEFAULT_PERSONALITY);
	this.set_u8("random move freq", 5);
	this.set_f32(target_searchrad_property, 320.0f);
	this.set_f32(terr_rad_property, 85.0f);
	this.set_u8(target_lose_random, 34);

	this.set_u32("next growl", 0);
	this.set_u32("next bite", 0);
	
	// this.getCurrentScript().removeIfTag = "dead";
	
	this.getBrain().server_SetActive(true);

	//for shape
	this.getShape().SetRotationsAllowed(false);

	//for flesh hit
	this.set_f32("gib health", -0.0f);

	this.Tag("flesh");
	this.Tag("badger");

	this.set_u8("number of steaks", 3);
	
	this.getShape().SetOffset(Vec2f(0, 0));
	
	this.getCurrentScript().runFlags |= Script::tick_blob_in_proximity;
	this.getCurrentScript().runProximityTag = "player";
	this.getCurrentScript().runProximityRadius = 320.0f;
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.SetLight(true);
	this.SetLightRadius(24.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.getHealth() < 5.0f; 
}

void onTick(CBlob@ this)
{
	if (this.hasTag("dead")) return;

	if (this.getHealth() < 3.0)
	{
		this.Tag("dead");
		this.setInventoryName("A Diced Bagel");

		Explode(this, 32.0f, 4.0f);

		for (int i = 0; i < 6; i++)
		{
			CBlob@ blob = server_CreateBlob("mat_mithril", this.getTeamNum(), this.getPosition());
			if (blob !is null)
			{
				blob.server_SetQuantity(10 + XORRandom(50));
				blob.setVelocity(Vec2f(4 - XORRandom(2), -2 - XORRandom(4)));
			}
		}
	}

	Vec2f vel = this.getVelocity();
	if (vel.x != 0.0f)
	{
		this.SetFacingLeft(vel.x < 0.0f ? true : false);
	}

	if (this.get_u32("next growl") < getGameTime() && XORRandom(100) < 10) 
	{
		this.set_u32("next growl", getGameTime() + 100);
		this.getSprite().PlaySound("bagel_growl" + (1 + XORRandom(2)) + ".ogg", 0.5f, 0.5f + XORRandom(100) / 400.0f);
	}

	if (this.get_u32("next bite") < getGameTime() && XORRandom(100) < 50) 
	{
		//this.set_u32("next bite", getGameTime() + 25);
		// this.getSprite().PlaySound("bagel_chomp.ogg", 0.4f, 0.9f);
		this.getSprite().SetAnimation("walk");
		EatMap(this);
	}
	
	if (this.isOnGround() && (this.isKeyPressed(key_left) || this.isKeyPressed(key_right)))
	{
		if ((this.getNetworkID() + getGameTime()) % 9 == 0)
		{
			const f32 volume = Maths::Min(0.1f + Maths::Abs(vel.x) * 0.1f, 1.0f);
			TileType tile = getMap().getTile(this.getPosition() + Vec2f(0.0f, this.getRadius() + 4.0f)).type;

			if (getMap().isTileGroundStuff(tile))
			{
				this.getSprite().PlaySound("/EarthStep", volume, 0.75f);
			}
			else
			{
				this.getSprite().PlaySound("/StoneStep", volume, 0.75f);
			}
		}
	}
}

void EatMap(CBlob@ this)
{
	CMap@ map = getMap();

	Vec2f pos = this.getPosition();
	Vec2f offset = Vec2f(this.isFacingLeft() ? -13 : 13, 0);
	
	map.server_DestroyTile(pos + offset, 0.1f, this);
	map.server_DestroyTile(pos + Vec2f(0, 0), 0.1f, this);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	this.set_u8(personality_property, AGGRO_BIT);
	MadAt(this, hitterBlob);
	return damage;
}

void MadAt(CBlob@ this, CBlob@ hitterBlob)
{
	if (hitterBlob is null) return;

	this.set_u8(personality_property, DEFAULT_PERSONALITY | AGGRO_BIT);
	this.set_u8(state_property, MODE_TARGET);
	
	if (hitterBlob.hasTag("player")) this.set_netid(target_property, hitterBlob.getNetworkID());
}

#include "Hitters.as";

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return !blob.hasTag("flesh");
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (blob is null) return;
	if (this.hasTag("dead")) return;
	if (this.get_u32("next bite") > getGameTime()) return;

	if (blob.getConfig() != this.getConfig())
	{
		this.getSprite().PlaySound("bagel_chomp.ogg", 1.0f, 1.2f);
		this.server_Hit(blob, point1, this.getVelocity(), 0.80f, Hitters::bite, false);
		
		MadAt(this, blob);
		EatMap(this);
		
		this.set_u32("next bite", getGameTime() + 15);
		this.set_u32("next growl", getGameTime() + 70);
	}
}

///SPRITE

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	if (!blob.hasTag("dead"))
	{
		Vec2f vel = blob.getVelocity();
		if (vel.x != 0.0f)
		{
			this.SetFacingLeft(vel.x < 0.0f ? true : false);
		}
		
		this.SetAnimation("walk");
	}
	else
	{
		this.SetAnimation("dead");
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
}
