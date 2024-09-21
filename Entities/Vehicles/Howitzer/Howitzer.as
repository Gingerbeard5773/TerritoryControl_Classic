#include "VehicleCommon.as";

// Howitzer Logic

const Vec2f arm_offset = Vec2f(-6, 0);

class HowitzerInfo : VehicleInfo
{
	void onFire(CBlob@ this, CBlob@ bullet, const u16 &in fired_charge)
	{
		if (bullet !is null)
		{
			if (isClient()) this.getSprite().getSpriteLayer("arm").SetAnimation("shoot");
			
			Random rand(bullet.getNetworkID());

			const f32 sign = this.isFacingLeft() ? -1 : 1;
			f32 angle = wep_angle * sign;
			angle += ((int(rand.NextRanged(200)) - 100) / 100.0f) * 2.0f;
			
			Vec2f vel = Vec2f((25.0f + (rand.NextRanged(100) / 100.0f) * 2.0f) * sign, 0.0f).RotateBy(angle);
			bullet.setVelocity(vel);
			
			Vec2f offset = Vec2f(sign * 16, 0);
			offset.RotateBy(angle);
			bullet.setPosition(this.getPosition() + offset);
			bullet.IgnoreCollisionWhileOverlapped(this);
			bullet.server_setTeamNum(this.getTeamNum());
			
			bullet.server_SetTimeToDie(-1);
			bullet.server_SetTimeToDie(20.0f);
		}
	}
}

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");

	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.1f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false,  // inventory access
				  HowitzerInfo()
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	Vehicle_AddAmmo(this, v,
	                    90, // fire delay (ticks)
	                    1, // fire bullets amount
	                    1, // fire cost
	                    "mat_howitzershell", // bullet ammo config name
	                    "Howitzer Shells", // name for ammo selection
	                    "howitzershell", // bullet config name
	                    "KegExplosion", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vec2f(-6.0f, 2.0f) //fire position offset
	);

	// init arm
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "Howitzer_Cannon.png", 32, 16);
	if (arm !is null)
	{
		{
			Animation@ anim = arm.addAnimation("default", 0, true);
			int[] frames = {0};
			anim.AddFrames(frames);
		}
	
		{
			Animation@ anim = arm.addAnimation("shoot", 1, false);
			int[] frames = {0, 1, 2, 3, 2, 1, 0};
			anim.AddFrames(frames);
		}
		
		arm.SetOffset(arm_offset);
		arm.SetRelativeZ(17.5f);
	}
	
	this.getShape().SetRotationsAllowed(false);
	
	string[] autograb = { "mat_howitzershell" };
	this.set("autograb blobs", autograb);

	sprite.SetZ(-10.0f);

	this.getCurrentScript().runFlags |= Script::tick_hasattached;

	// auto-load on creation
	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_howitzershell");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo)) ammo.server_Die();
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
	if (gunner !is null && gunner.getOccupied() !is null)
	{
		gunner.offsetZ = 5.0f;
		Vec2f aim_vec = gunner.getPosition() - gunner.getAimPos();

		if (this.isAttached())
		{
			if (facing_left) aim_vec.x = -aim_vec.x;
			angle = -aim_vec.getAngle() + 180.0f;
		}
		else
		{
			if ((!facing_left && aim_vec.x < 0) ||
			        (facing_left && aim_vec.x > 0))
			{
				if (aim_vec.x > 0) aim_vec.x = -aim_vec.x;

				angle = -aim_vec.getAngle() + 180.0f;
				angle = Maths::Max(-60.0f, Maths::Min(angle, 10.0f));
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
	if (this.hasAttached() || this.getTickSinceCreated() < 30) //driver, seat or gunner, or just created
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		//set the arm angle based on GUNNER mouse aim
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
			arm.RotateBy(rotation, Vec2f(4.0f * sign, 0.0f));
		}

		Vehicle_StandardControls(this, v);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}
