//Explode.as - Explosions

/**
 *
 * used mainly for void Explode (CBlob@ this, f32 radius, f32 damage)
 *
 * the effect of the explosion can be customised with properties:
 *
 * f32 map_damage_radius         - the radius to damage the map in
 * f32 map_damage_ratio          - the ratio of part-damage to full-damage of the map
 *                                   0.0 is all part-damage, 1.0 is all full-damage
 * bool map_damage_raycast       - whether to damage through terrain, or just the surface blocks;
 * bool map_destroy_ground       - whether to destroy ground tiles
 * bool map_damage_dirt          - whether to damage ground tiles
 *
 * string custom_explosion_sound - the sound played when the explosion happens
 *
 * u8 custom_hitter              - the hitter from Hitters.as to use
 */

#include "Hitters.as";
#include "ShieldCommon.as";
#include "SplashWater.as";
#include "CustomTiles.as";

void makeSmallExplosionParticle(Vec2f pos)
{
	ParticleAnimated("Entities/Effects/Sprites/SmallExplosion" + (XORRandom(3) + 1) + ".png", pos, Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);
}

void makeLargeExplosionParticle(Vec2f pos)
{
	ParticleAnimated("Entities/Effects/Sprites/Explosion.png", pos, Vec2f(0, 0.5f), 0.0f, 1.0f, 3 + XORRandom(3), -0.1f, true);
}

void Explode(CBlob@ this, const f32&in radius, const f32&in damage)
{
	Vec2f pos = this.getPosition() + this.get_Vec2f("explosion_offset");
	CMap@ map = getMap();

	if (!this.exists("custom_explosion_sound"))
	{
		Sound::Play("Bomb.ogg", this.getPosition());
	}
	else if (this.get_string("custom_explosion_sound") != "")
	{
		Sound::Play(this.get_string("custom_explosion_sound"), this.getPosition());
	}

	if (this.isInInventory())
	{
		CBlob@ doomed = this.getInventoryBlob();
		if (doomed !is null && !doomed.hasTag("invincible"))
		{
			this.server_Hit(doomed, pos, Vec2f(), 100.0f, Hitters::explosion, true);
		}
	}

	//load custom vars
	const f32 map_damage_radius = this.exists("map_damage_radius") ? this.get_f32("map_damage_radius") : 0.0f;
	const f32 map_damage_ratio = this.exists("map_damage_ratio") ? this.get_f32("map_damage_ratio") : 0.5f;
	const bool map_damage_raycast = this.exists("map_damage_raycast") ? this.get_bool("map_damage_raycast") : true;
	const u8 hitter = this.exists("custom_hitter") ? this.get_u8("custom_hitter") : Hitters::explosion;
	const bool should_teamkill = this.exists("explosive_teamkill") && this.get_bool("explosive_teamkill");

	const int r = (radius * (2.0 / 3.0));

	if (hitter == Hitters::water)
	{
		const int tilesr = (r / map.tilesize) * 0.5f;
		Splash(this, tilesr, tilesr, 0.0f);
		return;
	}

	// print("rad: " + radius + "; " + damage);
	ShakeScreen(damage * radius, 40.00f * Maths::FastSqrt(damage / 5.00f), pos);
	makeLargeExplosionParticle(pos);

	if (this.hasTag("bomberman_style"))
	{
		BombermanExplosion(this, radius, damage, hitter, should_teamkill);
		return; //------------------------------------------------------ END WHEN BOMBERMAN
	}

	if (isClient())
	{
		const int amount = radius * (v_fastrender ? 0.08f : 0.16f);
		for (int i = 0; i < amount; i++)
		{
			Vec2f partpos = pos + Vec2f(XORRandom(r * 2) - r, XORRandom(r * 2) - r);
			Vec2f endpos = partpos;
			if (!map.rayCastSolid(pos, partpos, endpos))
				makeSmallExplosionParticle(endpos);
		}
	}

	if (isServer())
	{
		//hit map if we're meant to
		if (map_damage_radius > 0.1f)
		{
			const int tile_rad = int(map_damage_radius / map.tilesize) + 1;
			const f32 rad_thresh = map_damage_radius * map_damage_ratio;
			Vec2f m_pos = (pos / map.tilesize);
			m_pos.x = Maths::Floor(m_pos.x);
			m_pos.y = Maths::Floor(m_pos.y);
			m_pos = (m_pos * map.tilesize) + Vec2f(map.tilesize * 0.5f, map.tilesize * 0.5f);

			//explode outwards
			for (int x_step = 0; x_step <= tile_rad; ++x_step)
			{
				for (int y_step = 0; y_step <= tile_rad; ++y_step)
				{
					Vec2f offset = (Vec2f(x_step, y_step) * map.tilesize);

					for (int i = 0; i < 4; i++)
					{
						if (i == 1 || i == 3)
						{
							if (x_step == 0) continue;
							offset.x = -offset.x;
						}

						if (i == 2)
						{
							if (y_step == 0) continue;
							offset.y = -offset.y;
						}

						const f32 dist = offset.Length();
						if (dist >= map_damage_radius) continue;

						//do we need to raycast?
						bool canHit = !map_damage_raycast || (dist < 0.1f);
						if (!canHit)
						{
							Vec2f v = offset;
							v.Normalize();
							v = v * (dist - map.tilesize);
							canHit = !map.rayCastSolid(m_pos, m_pos + v);
						}

						if (!canHit) continue;

						Vec2f tpos = m_pos + offset;
						Tile tile = map.getTile(tpos);

						canHit = this.hasTag("map_damage_dirt") || canExplosionDamage(map, tpos, tile);
						if (!canHit) continue;

						if (map.isTileBedrock(tile.type)) continue;

						if (dist >= rad_thresh || !canExplosionDestroy(this, map, tpos, tile.type))
						{
							map.server_DestroyTile(tpos, 1.0f, this);
						}
						else
						{
							map.server_DestroyTile(tpos, 100.0f, this);
						}
					}
				}
			}
		}

		//hit blobs
		CBlob@[] blobs;
		map.getBlobsInRadius(pos, radius, @blobs);

		for (uint i = 0; i < blobs.length; i++)
		{
			CBlob@ hit_blob = blobs[i];
			if (hit_blob is this) continue;
			
			/*const f32 force = Maths::Pow(radius * damage, 0.75f);
			Vec2f dir = hit_blob.getPosition() - pos;
			f32 distance = dir.getLength();
			if (distance < 5)
			{
				dir = Vec2f(0, 8);
				dir.RotateBy(XORRandom(360));
			}
			dir.Normalize();
			
			hit_blob.AddForce(dir * Maths::Min(force * (1.00f - (distance / radius)), hit_blob.getMass() * 4.0f));*/

			HitBlob(this, hit_blob, radius, damage, hitter, true, should_teamkill);
		}
	}
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (customData == Hitters::bomb || customData == Hitters::water)
	{
		hitBlob.AddForce(velocity);
	}
}

/**
 * Perform a linear explosion (a-la bomberman if in the cardinal directions)
 */

//vanilla compatibility
void LinearExplosion(CBlob@ this, Vec2f _direction, f32 length, const f32&in width,
                     const int&in max_depth, f32&in damage, const u8&in hitter, CBlob@[]@ blobs = null,
                     const bool&in should_teamkill = false)
{
	LinearExplosion(this, _direction, length, width, max_depth, damage, hitter, should_teamkill, false, blobs);
}

void LinearExplosion(CBlob@ this, Vec2f _direction, f32 length, const f32&in width,
                     const int&in max_depth, f32&in damage, const u8&in hitter,
                     const bool&in should_teamkill, const bool&in bother_raycasting = false, CBlob@[]@ blobs = null)
{
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();

	const f32 tilesize = map.tilesize;

	Vec2f direction = _direction;
	direction.Normalize();
	direction *= tilesize;

	const f32 halfwidth = width * 0.5f;

	Vec2f normal = direction;
	normal.RotateBy(90.0f, Vec2f());
	if (normal.y > 0) //so its the same normal for right and left
		normal.RotateBy(180.0f, Vec2f());

	pos += normal * -(halfwidth / tilesize + 1.0f);

	int steps = int(length / tilesize);
	const int width_steps = int(width / tilesize);
	int damagedsteps = 0;
	bool laststep = false;

	for (int step = 0; step <= steps; ++step)
	{
		bool damaged = false;

		Vec2f tpos = pos;
		for (int width_step = 0; width_step < width_steps + 2; width_step++)
		{
			bool justhurt = laststep || (width_step == 0 || width_step == width_steps + 1);
			tpos += normal;

			if (isClient())
			{
				if (v_fastrender && width_step % 2 != 0) continue;

				if (!justhurt && (((step + width_step) % 3 == 0) || XORRandom(3) == 0)) makeSmallExplosionParticle(tpos);
			}

			if (isServer())
			{
				Tile tile = map.getTile(tpos);
				if (tile.type == CMap::tile_bedrock || isTileIron(tile.type) || isTilePlasteel(tile.type))
				{
					if (tile.type != CMap::tile_bedrock)
					{
						map.server_DestroyTile(tpos, 100.0f, this);
					}
					if (!justhurt && width_step == width_steps / 2 + 1) //central only
					{
						steps = step;
						damagedsteps = max_depth; //blocked!
						break;
					}
				}
				else if (tile.type != CMap::tile_empty && tile.type != CMap::tile_ground_back)
				{
					if (this.hasTag("map_damage_dirt") || canExplosionDamage(map, tpos, tile))
					{
						if (!justhurt)
							damaged = true;

						justhurt = justhurt || !(this.hasTag("map_damage_dirt") ? true : canExplosionDestroy(this, map, tpos, tile.type));
						map.server_DestroyTile(tpos, justhurt ? 5.0f : 100.0f, this);
					}
					else
					{
						damaged = true;
					}
				}
			}
		}

		if (damaged)
			damagedsteps++;

		if (damagedsteps >= max_depth)
		{
			if (!laststep)
			{
				laststep = true;
			}
			else
			{
				steps = step;
				break;
			}
		}

		pos += direction;
	}

	if (!isServer()) return; //EARLY OUT ---------------------------------------- SERVER ONLY BELOW HERE

	//prevent hitting through walls
	length = steps * tilesize;

	// hit blobs

	pos = this.getPosition();
	direction.Normalize();
	normal.Normalize();

	if (blobs is null)
	{
		Vec2f tolerance(tilesize * 2, tilesize * 2);

		CBlob@[] tempblobs;
		@blobs = tempblobs;
		map.getBlobsInBox(pos - tolerance, pos + (direction * length) + tolerance, @blobs);
	}

	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ hit_blob = blobs[i];
		if (hit_blob is this) continue;

		const f32 rad = Maths::Max(tilesize, hit_blob.getRadius() * 0.25f);
		Vec2f hit_blob_pos = hit_blob.getPosition();
		Vec2f v = hit_blob_pos - pos;

		//lengthwise overlap
		f32 p = (v * direction);
		if (p > rad) p -= rad;
		if (p > tilesize) p -= tilesize;

		//widthwise overlap
		const f32 q = Maths::Abs(v * normal) - rad - tilesize;

		if (p > 0.0f && p < length && q < halfwidth)
		{
			HitBlob(this, hit_blob, length, damage, hitter, bother_raycasting, should_teamkill);
		}
	}
}

void BombermanExplosion(CBlob@ this, const f32&in radius, const f32&in damage, const u8&in hitter, const bool&in should_teamkill = false)
{
	const int steps = 4; //HACK
	const f32 ray_width = this.exists("map_bomberman_width") ? this.get_f32("map_bomberman_width") : 16.0f;

	//get blobs
	CBlob@[] blobs;
	getMap().getBlobsInRadius(this.getPosition(), radius, @blobs);

	LinearExplosion(this, Vec2f(0, -1), radius, ray_width, steps, damage, hitter, blobs, should_teamkill); //up
	LinearExplosion(this, Vec2f(0, 1), radius, ray_width, steps, damage, hitter, blobs, should_teamkill); //down
	LinearExplosion(this, Vec2f(-1, 0), radius, ray_width, steps, damage, hitter, blobs, should_teamkill); //left
	LinearExplosion(this, Vec2f(1, 0), radius, ray_width, steps, damage, hitter, blobs, should_teamkill); //right
}

bool canExplosionDamage(CMap@ map, Vec2f tpos, Tile&in tile)
{
	if (tile.type == CMap::tile_ground_d0 || tile.type == CMap::tile_stone_d0) return false; //don't _destroy ground, hit until its almost dead tho
	if (map.getSectorAtPosition(tpos, "no explode") !is null) return false;
	return map.isTileSolid(tile) || map.getSectorAtPosition(tpos, "no build") is null;
}

bool canExplosionDestroy(CBlob@ this, CMap@ map, Vec2f tpos, TileType t)
{
	return !map.isTileGroundStuff(t) || this.hasTag("map_destroy_ground");
}

bool HitBlob(CBlob@ this, CBlob@ hit_blob, const f32&in radius, const f32&in damage, const u8&in hitter, const bool&in bother_raycasting = true, const bool&in should_teamkill = false)
{
	Vec2f pos = this.getPosition();
	CMap@ map = getMap();
	Vec2f hit_blob_pos = hit_blob.getPosition();
	Vec2f hitvec = hit_blob_pos - pos;

	if (bother_raycasting)
	{
		HitInfo@[] hitInfos;
		if (map.getHitInfosFromRay(pos, -hitvec.getAngle(), hitvec.getLength(), this, @hitInfos))
		{
			for (uint i = 0; i < hitInfos.length; i++)
			{
				HitInfo@ hi = hitInfos[i];

				if (hi.blob is null) return false; //hit solid tile

				if (hi.blob is this || hi.blob is hit_blob || !hi.blob.isCollidable())
				{
					continue;
				}
				
				if (hi.blob.isPlatform())
				{
					ShapePlatformDirection@ plat = hi.blob.getShape().getPlatformDirection(0);
					Vec2f dir = plat.direction;
					if (!plat.ignore_rotations)
					{
						dir.RotateBy(hi.blob.getAngleDegrees());
					}
					
					Vec2f hitvec_dir = -hitvec;
					if (hit_blob.isPlatform() && hit_blob.getName() == "wooden_platform")
					{
						hitvec_dir = hitvec;
					}

					// Does the platform block damage
					if (Maths::Abs(dir.AngleWith(hitvec_dir)) < plat.angleLimit)
					{
						return false;
					}
					continue;
				}

				// only shield and heavy things block explosions
				if (hi.blob.hasTag("heavy weight") ||
				    hi.blob.getMass() > 500 || hi.blob.getShape().isStatic() ||
				   (hi.blob.hasTag("shielded") && blockAttack(hi.blob, hitvec, 0.0f)))
				{
					return false;
				}
			}
		}
	}

	if (isClient()) makeSmallExplosionParticle(hit_blob_pos);

	f32 scale;
	Vec2f bombforce = getBombForce(this, radius, hit_blob_pos, pos, hit_blob.getMass(), scale);
	const f32 dam = damage * scale;
	const bool can_teamkill = hitter == Hitters::water || this.getDamageOwnerPlayer() is hit_blob.getPlayer() || should_teamkill || hit_blob.hasTag("dead");
	this.server_Hit(hit_blob, hit_blob_pos, bombforce, dam, hitter, can_teamkill);
	return true;
}
