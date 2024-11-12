#include "VehicleCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "GunCommon.as";
#include "TC_Translation.as";

// Gatling Gun Logic

const Vec2f arm_offset = Vec2f(-4, 0);

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");

	this.addCommandID("client_fire");

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
	
	GunInfo gun;
	gun.bullet_damage = 1.5f;
	gun.bullet_range = 500.0f;
	gun.bullet_pierce_factor = 0.5f;
	gun.tracer_type = 0;

	this.set("gunInfo", @gun);

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

void onTick(CSprite@ this)
{	
	CSpriteLayer@ arm = this.getSpriteLayer("arm");
	if (arm.isAnimationEnded())
	{
		arm.SetAnimation("default");
	}
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
	
		const bool flip = this.isFacingLeft();
		const f32 aim_angle = v.wep_angle * (flip ? -1 : 1) + (flip ? 180 : 0);
		if (!isClient())
		{
			CBitStream stream;
			stream.write_Vec2f(this.getPosition());
			stream.write_f32(aim_angle);
			stream.write_u32(random);
			stream.write_u32(getGameTime());
			this.SendCommand(this.getCommandID("client_fire"), stream);
		}

		onFire(this, v, this.getPosition(), aim_angle, random, getGameTime());
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	if (cmd == this.getCommandID("client_fire") && isClient())
	{
		Vec2f position = params.read_Vec2f();
		const f32 aim_angle = params.read_f32();
		const u32 random = params.read_u32();
		const u32 game_time = params.read_u32();
		onFire(this, v, position, aim_angle, random, game_time);
	}
}

void onFire(CBlob@ this, VehicleInfo@ v, Vec2f position, const f32&in aim_angle, const u32&in random, const u32&in game_time)
{
	AmmoInfo@ ammo = v.getCurrentAmmo();
	if (ammo.loaded_ammo > 0)
	{
		v.last_fired_index = v.current_ammo_index;
		ammo.ammo_stocked -= ammo.loaded_ammo;
		ammo.loaded_ammo = 0;

		f32 angle = aim_angle;
		angle += ((int(random) - 150) / 100.0f);

		if (isClient())
		{
			ShakeScreen(18, 8, this.getPosition());
			CSprite@ sprite = this.getSprite();
			sprite.PlayRandomSound(ammo.fire_sound);
			sprite.getSpriteLayer("arm").SetAnimation("shoot");
		}

		CreateBullet(this, angle, position, game_time);
	}
	else
	{
		this.getSprite().PlayRandomSound(ammo.empty_sound);
	}

	v.fire_time = game_time + ammo.fire_delay;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}
