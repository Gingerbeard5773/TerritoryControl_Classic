#include "VehicleCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "TC_Translation.as";

// Gatling Gun Logic

const Vec2f arm_offset = Vec2f(-4, 0);
const f32 bullet_damage = 1.5f;
const f32 bullet_range = 500.0f;
const f32 bullet_pierce_factor = 0.5f;

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");
	
	this.addCommandID("fire bullet");
	this.addCommandID("fire bullet client");

	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.1f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	Vehicle_AddAmmo(this, v,
	                    3, // fire delay (ticks)
	                    1, // fire bullets amount
	                    1, // fire cost
	                    "mat_gatlingammo", // bullet ammo config name
	                    name(Translate::MachinegunAmmo), // name for ammo selection
	                    "", // bullet config name
	                    "GatlingGun-Shoot0", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vec2f(-6.0f, 2.0f) //fire position offset
	);

	// init arm + cage sprites
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "GatlingGun_Barrel.png", 24, 16);
	if (arm !is null)
	{
		{
			Animation@ anim = arm.addAnimation("default", 0, true);
			int[] frames = {0};
			anim.AddFrames(frames);
		}
	
		{
			Animation@ anim = arm.addAnimation("shoot", 1, false);
			int[] frames = {0, 2, 1};
			anim.AddFrames(frames);
		}
		
		arm.SetOffset(arm_offset);
		arm.SetRelativeZ(17.5f);
	}

	this.getShape().SetRotationsAllowed(false);
	
	string[] autograb = { "mat_gatlingammo" };
	this.set("autograb blobs", autograb);
	
	sprite.SetZ(-10.0f);
	
	this.getCurrentScript().runFlags |= Script::tick_hasattached;

	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_gatlingammo");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo))
				ammo.server_Die();
		}
	}
}

void onInit(CSprite@ this)
{
	CSpriteLayer@ tracer = this.addSpriteLayer("tracer", "GatlingGun_Tracer.png" , 32, 1);
	if (tracer !is null)
	{
		tracer.SetRelativeZ(-1.0f);
		tracer.SetVisible(false);
		tracer.setRenderStyle(RenderStyle::additive);
	}
}

void onTick(CSprite@ this)
{	
	CSpriteLayer@ arm = this.getSpriteLayer("arm");
	if (arm.isAnimationEnded())
	{
		arm.SetAnimation("default");
	}
	
	CBlob@ blob = this.getBlob();
	VehicleInfo@ v;
	if (!blob.get("VehicleInfo", @v)) return;
	
	if (getGameTime() >= v.fire_time - 1)
		this.getSpriteLayer("tracer").SetVisible(false);
}

f32 getAimAngle(CBlob@ this, VehicleInfo@ v)
{
	f32 angle = v.wep_angle;
	const bool facing_left = this.isFacingLeft();
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");
	bool failed = true;

	if (gunner !is null && gunner.getOccupied() !is null)
	{
		gunner.offsetZ = 5.0f;
		Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if (this.isAttached())
		{
			if (facing_left) aim_vec.x = -aim_vec.x;
			angle = (-(aim_vec).getAngle() + 180.0f);
		}
		else
		{
			if ((!facing_left && aim_vec.x < 0) ||
			        (facing_left && aim_vec.x > 0))
			{
				if (aim_vec.x > 0) aim_vec.x = -aim_vec.x;

				angle = -aim_vec.getAngle() + 180.0f;
				angle = Maths::Max(-90.0f, Maths::Min(angle, 50.0f));
			}
			else
			{
				this.SetFacingLeft(!facing_left);
			}
		}
	}

	return angle;
}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30)
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		f32 angle = getAimAngle(this, v);
		v.wep_angle = angle;

		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");
		if (arm !is null)
		{
			const bool facing_left = sprite.isFacingLeft();
			const f32 sign = facing_left ? -1 : 1;
			angle -= this.getAngleDegrees() * sign;
			const f32 rotation = angle * sign;

			arm.ResetTransform();
			arm.SetFacingLeft(facing_left);
			arm.SetOffset(arm_offset);
			arm.RotateBy(rotation, Vec2f(sign * 4.0f, 0.0f));
		}
		
		Vehicle_GatlingControls(this, v);
	}
}

void Vehicle_GatlingControls(CBlob@ this, VehicleInfo@ v)
{
	if (!isServer()) return;

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("GUNNER");
	CBlob@ caller = ap.getOccupied();
	if (caller is null) return;

	if (ap.isKeyJustPressed(key_up))
	{
		this.server_DetachFrom(caller);
		return;
	}

	if (ap.isKeyPressed(key_action1) && getGameTime() > v.fire_time)
	{
		const u32 random = XORRandom(300);

		if (!isClient())
		{
			CBitStream bt;
			bt.write_netid(caller.getNetworkID());
			bt.write_u32(random);
			this.SendCommand(this.getCommandID("fire bullet client"), bt);
		}

		onFire(this, v, caller, random);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	if (cmd == this.getCommandID("fire bullet client") && isClient())
	{
		CBlob@ caller = getBlobByNetworkID(params.read_netid());
		if (caller is null) return;

		const u32 random = params.read_u32();
		onFire(this, v, caller, random);
	}
}

void onFire(CBlob@ this, VehicleInfo@ v, CBlob@ caller, const u32&in random)
{	
	AmmoInfo@ ammo = v.getCurrentAmmo();
	if (ammo.loaded_ammo > 0)
	{
		this.getSprite().PlayRandomSound(ammo.fire_sound);
		v.last_fired_index = v.current_ammo_index;
		ammo.ammo_stocked -= ammo.loaded_ammo;
		ammo.loaded_ammo = 0;
		
		FireBullet(this, v, caller, random);
	}
	else
	{
		this.getSprite().PlayRandomSound(ammo.empty_sound);
	}

	v.fire_time = getGameTime() + ammo.fire_delay;
}

void FireBullet(CBlob@ this, VehicleInfo@ v, CBlob@ caller, const u32&in random)
{
	const bool flip = this.isFacingLeft();
	f32 angle = v.wep_angle * (flip ? -1 : 1);
	angle += ((int(random) - 150) / 100.0f);

	Vec2f dir = Vec2f(flip ? -1 : 1, 0.0f).RotateBy(angle);
	Vec2f position = this.getPosition();

	CMap@ map = getMap();
	f32 length = bullet_range;
	
	HitInfo@[] hitInfos;
	if (map.getHitInfosFromRay(position, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos))
	{
		f32 falloff = 1;
		for (u32 i = 0; i < hitInfos.length; i++)
		{
			HitInfo@ hit = hitInfos[i];
			CBlob@ blob = hit.blob;
			if (blob is null)
			{
				if (isServer())
				{
					Tile tile =	map.getTile(hit.tileOffset);
					if (map.isTileSolid(tile) && !map.isTileBedrock(tile.type) && tile.type != CMap::tile_ground_d0 && tile.type != CMap::tile_stone_d0)
					{
						map.server_DestroyTile(hit.hitpos, bullet_damage * 0.125f);
					}
				}
				length = (hit.hitpos - position).Length();
				break;
			}

			if (blob.isPlatform() && !CollidesWithPlatform(blob, -dir)) continue;

			const bool willHit = this.getTeamNum() == blob.getTeamNum() ? blob.getShape().isStatic() : true; 

			if (blob.hasTag("no pickup") && blob.get_u8("bomber team") == this.getTeamNum()) continue; //do not kill our own bomber's bombs

			if (blob.isCollidable() && willHit && !blob.hasTag("invincible") && !blob.hasTag("gun"))
			{
				this.server_Hit(blob, hit.hitpos, dir, bullet_damage * Maths::Max(0.1, falloff), HittersTC::bullet, true);
				falloff *= bullet_pierce_factor;

				if (blob.getShape().isStatic())
				{
					length = (hit.hitpos - position).Length();
					break;
				}
			}
		}
	}
	
	if (isClient())
	{
		length /= 32;
		
		CSprite@ sprite = this.getSprite();
		sprite.getSpriteLayer("arm").SetAnimation("shoot");
		
		CSpriteLayer@ tracer = sprite.getSpriteLayer("tracer");
		tracer.SetVisible(true);
		tracer.ResetTransform();
		tracer.ScaleBy(Vec2f(length, 1.0f));
		tracer.TranslateBy(Vec2f(length * 16.0f, 0.0f));
		angle -= this.getAngleDegrees();
		tracer.RotateBy(angle + (flip ? 180 : 0), Vec2f());
	}
}

bool CollidesWithPlatform(CBlob@ blob, Vec2f velocity)
{	
	Vec2f direction = Vec2f(0.0f, -1.0f).RotateBy(blob.getAngleDegrees());
	const f32 velocity_angle = direction.AngleWith(velocity);
	return velocity_angle > -90.0f && velocity_angle < 90.0f;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}
