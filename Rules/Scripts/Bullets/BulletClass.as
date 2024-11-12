
// BulletClass.as - Vamist

//Gingerbeard @ November 9, 2024

#include "ParticleSparks.as";
#include "MakeDustParticle.as";
#include "HittersTC.as";
#include "CustomTiles.as";
#include "GunCommon.as";

Driver@ PDriver = getDriver();

class Bullet
{
	u16 gun_netid;     //netid of the gun blob
	Vec2f init_pos;    //initial position the bullet was created
	Vec2f current_pos; //current position the bullet is at
	Vec2f old_pos;     //previous position the bullet was at
	Vec2f velocity;    //velocity the bullet is traveling at
	f32 penetration;   //penetration value for calculating damage
	f32 range;         //range of the bullet that it can travel
	u8 tracer_type;    //index of png we will use
	bool killed;       //bullet death
	BulletFade@ fade;  //fade

	Bullet(CBlob@ gun, const f32&in angle, const Vec2f&in pos)
	{
		gun_netid = gun.getNetworkID();
		current_pos = old_pos = init_pos = pos;
		killed = false;
		penetration = 1.0f;
		
		Vec2f direction = Vec2f(1, 0.0f).RotateBy(angle);
		velocity = direction * 80.0f;
		
		range = 0.0f;
		tracer_type = 0;
		
		CBlob@ gunBlob = getBlobByNetworkID(gun_netid);
		if (gunBlob !is null)
		{
			GunInfo@ gun;
			if (gunBlob.get("gunInfo", @gun))
			{
				range = gun.bullet_range;
				tracer_type = gun.tracer_type;
			}
		}
		@fade = BulletFade(@this);
	}

	bool Tick(CMap@ map)
	{
		const Vec2f dim = map.getMapDimensions();
		const bool LeftMap = current_pos.x < 0 || current_pos.y < 0 || current_pos.x > dim.x || current_pos.y > dim.y;
		if (LeftMap || killed) return true;

		// Update bullet position
		old_pos = current_pos;
		current_pos += velocity;
		
		CBlob@ gunBlob = getBlobByNetworkID(gun_netid);
		if (gunBlob is null) return true;
		
		GunInfo@ gun;
		if (!gunBlob.get("gunInfo", @gun)) return true;
		
		const f32 distance_covered = (current_pos - init_pos).Length();
		if (distance_covered > range)
		{
			killed = true;
		}
		
		HitTargets(map, gunBlob, gun);

		return false;
	}
	
	void HitTargets(CMap@ map, CBlob@ gunBlob, GunInfo@ gun)
	{
		Vec2f ray = current_pos - old_pos;
		Vec2f dir = ray;
		dir.Normalize();

		HitInfo@[] list;
		if (!map.getHitInfosFromRay(old_pos, -ray.Angle(), ray.Length(), gunBlob, @list)) return;

		for (int i = 0; i < list.length; i++)
		{
			HitInfo@ hit = list[i];
			Vec2f hitpos = hit.hitpos;
			CBlob@ blob = hit.blob;
			if (blob !is null)
			{
				if (CanHitBlob(gunBlob, blob, ray))
				{
					killed = penetration <= 0.15f || (blob.getShape().isStatic() && blob.getShape().getConsts().support > 0);

					gunBlob.server_Hit(blob, hitpos, dir, gun.bullet_damage * Maths::Max(0.1, penetration), HittersTC::bullet, true);
					penetration *= gun.bullet_pierce_factor;
				}
			}
			else
			{
				Tile tile = map.getTile(hit.tileOffset);
				if (CanHitTile(map, tile, gun))
				{
					map.server_DestroyTile(hitpos, gun.bullet_damage * 0.25f);
				}
				else if (map.isTileSolid(tile) && (!map.isTileGroundStuff(tile.type) || map.isTileBedrock(tile.type)))
				{
					if (isTileIron(tile.type) || isTilePlasteel(tile.type))
					{
						Sound::Play("BulletRico"+XORRandom(4), hitpos, 1.0f);
					}
					sparks(hitpos, -ray.Angle(), gun.bullet_damage * 0.5f);
				}

				if (map.isTileGroundStuff(tile.type) && !map.isTileBedrock(tile.type))
				{
					Sound::Play("BulletDirt"+XORRandom(2), hitpos, 1.0f);
					MakeDustParticle(hitpos, "DustSmall.png");
				}

				if (!isTileGlass(tile.type))
				{
					killed = true;
				}
			}

			if (killed)
			{
				current_pos = hitpos;
				break;
			}
		}
	}
	
	bool CanHitBlob(CBlob@ gunBlob, CBlob@ blob, Vec2f&in ray)
	{
		if (blob.isPlatform())
		{
			ShapePlatformDirection@ plat = blob.getShape().getPlatformDirection(0);
			Vec2f dir = plat.direction;
			if (!plat.ignore_rotations) dir.RotateBy(blob.getAngleDegrees());

			if (Maths::Abs(dir.AngleWith(ray)) < plat.angleLimit)
				return false; //passed through platform
		}

		if (blob.hasTag("no pickup") && blob.get_u8("bomber team") == gunBlob.getTeamNum())
			return false; //do not kill our own bomber's bombs

		const bool willHit = gunBlob.getTeamNum() == blob.getTeamNum() ? blob.getShape().isStatic() : true; 
		if (blob.isCollidable() && willHit && !blob.hasTag("invincible") && !blob.hasTag("gun"))
			return true;

		return false;
	}
	
	bool CanHitTile(CMap@ map, const Tile&in tile, GunInfo@ gun)
	{
		if (map.isTileBedrock(tile.type))
			return false;

		if (isTilePlasteel(tile.type) && gun.bullet_damage < 4.0f)
			return false;

		if (gun.bullet_pierce_factor <= 0.5f && (tile.type == CMap::tile_ground_d0 || tile.type == CMap::tile_stone_d0))
			return false; //pierce is too weak to destroy ground tiles

		if ((map.isTileWood(tile.type) || gun.bullet_damage >= 1.5f))
			return true;

		return false;
	}

	void JoinQueue(const f32&in screenWidth) // Every bullet gets forced to join the queue in onRenders, so we use this to calc to position
	{   
		// Are we on the screen?
		const Vec2f xLast = PDriver.getScreenPosFromWorldPos(old_pos);
		const Vec2f xNew  = PDriver.getScreenPosFromWorldPos(current_pos);
		if (!(xNew.x > 0 && xNew.x < screenWidth)) // Is our main position still on screen?
		{
			if (!(xLast.x > 0 && xLast.x < screenWidth)) // Was our last position on screen?
			{
				return; // No, lets not stay here then
			}
		}

		Vec2f new_pos = Vec2f_lerp(old_pos, current_pos, FRAME_TIME);

		Vec2f TopLeft  = Vec2f(new_pos.x - 5.0f, new_pos.y - 1);
		Vec2f TopRight = Vec2f(new_pos.x - 5.0f, new_pos.y + 1);
		Vec2f BotLeft  = Vec2f(new_pos.x + 5.0f, new_pos.y - 1);
		Vec2f BotRight = Vec2f(new_pos.x + 5.0f, new_pos.y + 1);

		const f32 angle = -velocity.Angle();

		BotLeft.RotateBy( angle, new_pos);
		BotRight.RotateBy(angle, new_pos);
		TopLeft.RotateBy( angle, new_pos);
		TopRight.RotateBy(angle, new_pos);

		Vertex[]@ vertex_bullet = vertex_bullet_book[tracer_type];

		vertex_bullet.push_back(Vertex(TopLeft.x,  TopLeft.y,  0, 0, 0, color_white)); // top left
		vertex_bullet.push_back(Vertex(TopRight.x, TopRight.y, 0, 1, 0, color_white)); // top right
		vertex_bullet.push_back(Vertex(BotRight.x, BotRight.y, 0, 1, 1, color_white)); // bot right
		vertex_bullet.push_back(Vertex(BotLeft.x,  BotLeft.y,  0, 0, 1, color_white)); // bot left

		fade.onRender(new_pos);
	}
}

class BulletHolder
{
	Bullet[] bullets;
	BulletHolder(){}

	void Tick()
	{
		CMap@ map = getMap();
		for (int i = 0; i < bullets.length; i++)
		{
			Bullet@ bullet = bullets[i];
			if (bullet.Tick(map))
			{
				bullets.erase(i);
				i--;
			}
		}
	}
	
	void FillArray()
	{
		const f32 screenWidth = PDriver.getScreenWidth();
		for (int i = 0; i < bullets.length; i++)
		{
			bullets[i].JoinQueue(screenWidth);
		}
	}

	void AddNewBullet(Bullet@ bullet)
	{
		CMap@ map = getMap();
		bullet.Tick(map);
		bullets.push_back(bullet);
	}
}

class BulletFade
{
	Bullet@ bullet;
	SColor back_color = SColor(0, 255, 255, 255);

    BulletFade(Bullet@ bullet_)
    {
		@bullet = bullet_;
    }

    void onRender(Vec2f&in front)
    {
		Vec2f back = bullet.init_pos;
		const f32 distance_covered = Maths::Min((front - back).Length() / bullet.range, 1.0f);

		back += (front - back) * 0.75f * distance_covered;

		back_color.setAlpha(1.0f - distance_covered);

		Vec2f over(0, 1);
		Vec2f under(0, -1);
		Vec2f aim = back - front;
		const f32 angle = -aim.AngleDegrees();

		over.RotateByDegrees(angle);
		under.RotateByDegrees(angle);
		
		Vertex[]@ vertex_fade = vertex_fade_book[bullet.tracer_type];

		vertex_fade.push_back(Vertex(front.x+under.x, front.y+under.y, 1, 0, 1, color_white)); //top left
		vertex_fade.push_back(Vertex(front.x+over.x, front.y+over.y, 1, 1, 1, color_white)); //top right
		vertex_fade.push_back(Vertex(back.x+over.x*0.5f, back.y+over.y*0.5f,1, 1, 0, back_color)); //bot right
		vertex_fade.push_back(Vertex(back.x+under.x*0.5f, back.y+under.y*0.5f,1, 0, 0, back_color)); //bot left
    }
}
