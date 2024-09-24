
#include "Hitters.as";
#include "FireParticle.as";
#include "BombCommon.as";
#include "SplashWater.as";
#include "Knocked.as";

namespace card
{
	enum type
	{
		death = 0,
		holy,
		nature,
		water,
		fire,
		cog,
		steam,
		mine
	}
}

void onInit(CBlob@ this)
{
	CShape@ shape = this.getShape();
	ShapeConsts@ consts = shape.getConsts();
	consts.bullet = false;
	consts.net_threshold_multiplier = 4.0f;
	this.Tag("projectile");
	
	this.addCommandID("client_card_collide");
	
	this.server_SetTimeToDie(3);
	this.getShape().SetGravityScale(0);
	this.set_u8("type", 0);
}

void onInit(CSprite@ this)
{
	this.PlaySound("woosh.ogg", 1, 1);
	this.getCurrentScript().tickFrequency = 2;
}

void onTick(CSprite@ this)
{
	this.RotateBy(20, Vec2f());
	
	CBlob@ blob = this.getBlob();
	Vec2f pos = blob.getPosition();
	switch (blob.get_u8("type"))
	{
		case card::death:  makeSmokeParticle(pos);                             break;
		case card::holy:   sparks(pos, 90, 5, SColor(255, 255, 255, 0));       break;
		case card::nature: makeNatureParticle(pos);                            break;	
		case card::water:  sparks(pos, 0, 0, SColor(255, 44, 175, 222));       break;
		case card::fire:   makeFireParticle(pos);                              break;
		case card::steam:  makeSteamParticle(blob, blob.getVelocity() * 0.05); break;
	}
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	Vec2f random = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.015625f * this.getRadius();
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + random, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void makeSteamPuff(CBlob@ this)
{
	this.getSprite().PlaySound("Steam.ogg");

	makeSteamParticle(this, Vec2f(), "MediumSteam");
	for (int i = 0; i < 10; i++)
	{
		f32 randomness = (XORRandom(32) + 32) * 0.015625f * 0.5f + 0.75f;
		Vec2f vel = getRandomVelocity(-90, randomness, 360.0f);
		makeSteamParticle(this, vel);
	}
}

void makeNatureParticle(Vec2f pos)
{
	Vec2f position = pos + Vec2f(XORRandom(8) - 4, 2 + XORRandom(4));
	Vec2f velocity = Vec2f(XORRandom(4) - 2, -XORRandom(2));
	makeGibParticle("GenericGibs.png", position, velocity, 7, 1 + XORRandom(4), Vec2f(8, 8), 2.0f, 20, "Gurgle2", 0);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	if (!isServer() || this.hasTag("collided")) return;

	if ((blob !is null && doesCollideWithBlob(this, blob)) || solid)
	{
		this.Tag("collided");

		if (!isClient()) //no localhost
		{
			CBitStream stream;
			stream.write_netid(blob !is null ? blob.getNetworkID() : 0);
			this.SendCommand(this.getCommandID("client_card_collide"), stream);
		}

		onCardCollision(this, blob);
		this.server_Die();
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client_card_collide") && isClient())
	{
		CBlob@ blob = getBlobByNetworkID(params.read_netid());
		onCardCollision(this, blob);
	}
}

void onCardCollision(CBlob@ this, CBlob@ blob)
{
	switch (this.get_u8("type"))
	{
		case card::death:  CardDeath(this, blob);   break;
		case card::holy:   CardHoly(this, blob);    break;
		case card::nature: CardNature(this, blob);  break;
		case card::water:  CardWater(this, blob);   break;
		case card::fire:   CardFire(this, blob);    break;
		case card::cog:    CardCog(this, blob);     break;
		case card::steam:  CardSteam(this, blob);   break;
		case card::mine:   CardMine(this, blob);    break;
	}

	CSprite@ sprite = this.getSprite();
	sprite.PlaySound("card_sparkle.ogg", 1, 1);
	ParticlesFromSprite(sprite);
}

void CardDeath(CBlob@ this, CBlob@ blob)
{
	if (blob is null || !isServer()) return;

	this.server_Hit(blob, blob.getPosition(), this.getVelocity(), 2.5f, Hitters::crush);
}

void CardHoly(CBlob@ this, CBlob@ blob)
{
	if (blob is null || !isServer()) return;

	blob.server_Heal(20);
}

void CardNature(CBlob@ this, CBlob@ blob)
{
	if (!isServer()) return;

	if (blob !is null)
	{
		blob.server_Heal(2);
	}
	
	CMap@ map = getMap();
	const int radius = 10;
	Vec2f pos = this.getPosition();
	const f32 radsq = radius * 8 * radius * 8;

	for (int x_step = -radius; x_step < radius; ++x_step)
	{
		for (int y_step = -radius; y_step < radius; ++y_step)
		{
			Vec2f off(x_step * map.tilesize, y_step * map.tilesize);

			if (off.LengthSquared() > radsq) continue;

			Vec2f tpos = pos + off;
			if (!map.isTileGround(map.getTile(tpos + Vec2f(0, 8)).type)) continue;

			TileType t = map.getTile(tpos).type;
			if (t == CMap::tile_empty)
			{
				map.server_SetTile(tpos, CMap::tile_grass);
			}
			
			if (!map.isTileSolid(t))
			{
				if (XORRandom(2) == 0)server_CreateBlob("bush", -1, tpos);
				else
				{
					CBlob@ flow = server_CreateBlob("flowers", -1, tpos);
					flow.Tag("instant_grow");
				}
				if (XORRandom(4) == 0)
				{
					CBlob@ grain = server_CreateBlobNoInit("grain_plant");
					if (grain !is null)
					{
						grain.Tag("instant_grow");
						grain.setPosition(tpos);
						grain.Init();
					}
				}
			}
		}
	}
}

void CardWater(CBlob@ this, CBlob@ blob)
{
	Splash(this, 3, 3, 0.0f, true);
	this.getSprite().PlaySound("GlassBreak");
}

void CardFire(CBlob@ this, CBlob@ blob)
{
	this.getSprite().PlaySound("FireFwoosh");

	if (!isServer()) return;
	
	if (blob !is null)
	{
		this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 1.0f, Hitters::fire);
	}
	
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();
	const int radius = 2; //size of the circle
	const f32 radsq = radius * 8 * radius * 8;
	for (int x_step = -radius; x_step < radius; ++x_step)
	{
		for (int y_step = -radius; y_step < radius; ++y_step)
		{
			Vec2f off(x_step * map.tilesize, y_step * map.tilesize);
			if (off.LengthSquared() > radsq) continue;
			
			map.server_setFireWorldspace(pos + off, true);
		}
	}
}

void CardCog(CBlob@ this, CBlob@ blob)
{
	if (isServer() && blob !is null && blob.hasTag("vehicle"))
	{
		blob.server_Heal(20);
	}
}

void CardSteam(CBlob@ this, CBlob@ blob)
{
	if (isServer() && blob !is null)
	{
		for (u8 i = 0; i < 4; i++)
		{
			this.server_Hit(blob, blob.getPosition(), this.getVelocity() * 20.0f, 0.5f, Hitters::nothing);
		}
	}
	
	makeSteamPuff(this);
}

void CardMine(CBlob@ this, CBlob@ blob)
{
	if (!isServer()) return;

	CMap@ map = getMap();
	const int radius = 10;
	Vec2f pos = this.getPosition();
	const f32 radsq = radius * 8 * radius * 8;

	for (int x_step = -radius; x_step < radius; ++x_step)
	{
		for (int y_step = -radius; y_step < radius; ++y_step)
		{
			Vec2f off(x_step * map.tilesize, y_step * map.tilesize);

			if (off.LengthSquared() > radsq) continue;

			Vec2f tpos = pos + off;

			TileType t = map.getTile(tpos).type;
			if (map.isTileGround(t))
			{
				int typ = CMap::tile_stone;
				if (XORRandom(2) == 0)
				{
					typ = 100 + XORRandom(5);
				}
				else
				{
					typ = 215 + XORRandom(4);
				}
				
				map.server_SetTile(tpos, typ);
			}
		}
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (!blob.isCollidable()) return false;

	if (blob.getShape().isStatic()) return true;

	if (blob.hasTag("projectile") || blob.hasTag("dead")) return false;
	
	const u8 type = this.get_u8("type");
	if (type == card::cog && blob.hasTag("vehicle")) return true;

	if (this.getDamageOwnerPlayer() is blob.getPlayer()) return false;
	
	if (this.getTeamNum() == blob.getTeamNum())
	{
		if (type == card::death || type == card::water || type == card::fire || type == card::steam) return false;
	}

	return true;
}
