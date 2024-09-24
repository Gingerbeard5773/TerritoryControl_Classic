#include "VehicleCommon.as";
#include "VehicleAttachmentCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "Explosion.as";

const Vec2f arm_offset = Vec2f(-2, -4);

class SteamTankInfo : VehicleInfo
{
	void onFire(CBlob@ this, CBlob@ bullet, const u16 &in fired_charge)
	{
		if (bullet !is null)
		{
			Random rand(bullet.getNetworkID());
			const f32 sign = this.isFacingLeft() ? -1 : 1;
			f32 angle = wep_angle * sign;
			angle += ((int(rand.NextRanged(200)) - 100) / 100.0f);
			angle += this.getAngleDegrees();

			Vec2f vel = Vec2f(30.0f * sign, 0.0f).RotateBy(angle);
			bullet.setVelocity(vel);

			Vec2f offset = Vec2f(sign * 26, -4);
			offset.RotateBy(angle);
			bullet.setPosition(this.getPosition() + offset);
			bullet.server_SetTimeToDie(20.0f);
			bullet.IgnoreCollisionWhileOverlapped(this);
			bullet.server_setTeamNum(this.getTeamNum());

			if (isClient())
			{
				Vec2f dir = Vec2f(sign, 0.0f).RotateBy(angle);
				ParticleAnimated("SmallExplosion.png", this.getPosition() + offset, dir, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
			}
			this.set_f32("gun_recoil_current", 5);
		}
	}
}

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              80.0f, // move speed
	              0.40f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              true,  // inventory access
	              SteamTankInfo()
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;
	
	Vehicle_AddAmmo(this, v,
	                    40, // fire delay (ticks)
	                    1, // fire bullets amount
	                    1, // fire cost
	                    "mat_tankshell", // bullet ammo config name
	                    "Tank Shells", // name for ammo selection
	                    "tankshell", // bullet config name
	                    "KegExplosion", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vec2f(-6.0f, 2.0f) //fire position offset
	);
		
	this.set_f32("hit dmg modifier", 20.0f);
	this.set_f32("map dmg modifier", 40.0f);
	
	this.set_string("custom_explosion_sound", "KegExplosion");
	
	this.getShape().SetOffset(Vec2f(0, 8));
	
	this.Tag("blocks sword");
	
	this.Tag("invincible attachments"); //set our attached blobs as invincible
	
	Vehicle_SetupGroundSound(this, v, "machinery_out_lp_03", 0.8f, 1.0f);
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-12.0f, 12.0f));
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(-1.0f, 12.0f));
	Vehicle_addWheel(this, v, "WoodenWheels.png", 16, 16, 0, Vec2f(10.0f, 12.0f));
	
	AttachmentPoint@ driverpoint = this.getAttachments().getAttachmentPointByName("DRIVER");
	if (driverpoint !is null)
	{
		driverpoint.SetKeysToTake(key_action1);
	}

	CSprite@ sprite = this.getSprite();
	sprite.SetZ(10.0f);
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "SteamTank_Cannon.png", 32, 8);
	if (arm !is null)
	{
		arm.SetOffset(arm_offset);
		arm.SetRelativeZ(1.0f);
	}

	this.getShape().SetRotationsAllowed(true);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	string[] autograb = { "mat_tankshell" };
	this.set("autograb blobs", autograb);

	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_tankshell");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo))
				ammo.server_Die();
		}
	}
}

f32 getAimAngle(CBlob@ this, VehicleInfo@ v)
{
	f32 angle = v.wep_angle;
	const bool facing_left = this.isFacingLeft();
	AttachmentPoint@ gunner = this.getAttachments().getAttachmentPointByName("GUNNER");
	if (gunner !is null && gunner.getOccupied() !is null)
	{
		Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();
		aim_vec.RotateBy(-this.getAngleDegrees());

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

				angle = -(aim_vec).getAngle() + 180.0f;
				angle = Maths::Max(-60.0f, Maths::Min(angle, 5.0f));
			}
		}
	}

	return angle;
}

void onTick(CBlob@ this)
{
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		this.set_f32("gun_recoil_current", Maths::Lerp(this.get_f32("gun_recoil_current"), 0, 0.45f));

		//set the arm angle based on GUNNER mouse aim, see above ^^^^
		const f32 angle = getAimAngle(this, v);
		v.wep_angle = angle;
		CSprite@ sprite = this.getSprite();

		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");
		if (arm !is null)
		{
			const bool facing_left = sprite.isFacingLeft();
			const f32 rotation = angle * (facing_left ? -1 : 1);

			arm.ResetTransform();
			arm.SetRelativeZ(-1.0f);
			arm.SetOffset(Vec2f(this.get_f32("gun_recoil_current"), 0).RotateBy(-getAimAngle(this, v)) + arm_offset);
			arm.RotateBy(rotation, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
		}

		Vehicle_StandardControls(this, v);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return this.getTeamNum() != blob.getTeamNum() ? blob.isCollidable() : false;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob, "CARGO");
	}
}

void onDie(CBlob@ this)
{
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;
	
	Explode(this, 32.0f, 4.0f);
	
	const int loadedAmmo = v.getCurrentAmmo().loaded_ammo;
	
	Random rand(this.getNetworkID());
	
	for (int i = 0; i < 2 + rand.NextRanged(3); i++)
	{
		Vec2f dir = Vec2f((100 - int(rand.NextRanged(200))) / 100.0f, (100 - int(rand.NextRanged(200))) / 100.0f);
		LinearExplosion(this, dir, 5.0f * 1 + loadedAmmo, 3.0f * 1 + loadedAmmo, 8, 8.0f, Hitters::explosion);
	}
	
	/*if (isServer())
	{
		CBlob@ blob = server_CreateBlob("steamtankwreck", this.getTeamNum(), this.getPosition());
	}*/
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	f32 dmg = damage;
	switch (customData)
	{
		case Hitters::sword:
		case Hitters::arrow:
		case Hitters::stab:
			dmg *= 0.25f;
			break;
		case Hitters::builder:
			dmg *= 4.0f;
			break;
		case Hitters::drill:
			dmg *= 2.5f;
			break;
		case Hitters::bomb:
			dmg *= 4.0f;
			break;
		case Hitters::mine:
			dmg *= 3.5f;
			break;
		case Hitters::keg:
		case Hitters::explosion:
			dmg *= 2.0f;
			break;
		case Hitters::bomb_arrow:
			dmg *= 4.00f;
			break;
		case Hitters::flying: // boat ram
			dmg *= 0.5f;
			break;
		case HittersTC::bullet:
			dmg *= 0.25f;
			break;
	}

	return dmg;
}
