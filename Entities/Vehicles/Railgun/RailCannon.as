#include "VehicleCommon.as"

// Rail Cannon Logic

class RailCannonInfo : VehicleInfo
{
	void onFire(CBlob@ this, CBlob@ bullet, const u16 &in fired_charge)
	{
		if (bullet !is null)
		{
			f32 angle = wep_angle;
			angle = angle * (this.isFacingLeft() ? -1 : 1);
			
			Vec2f vel = Vec2f(45.0f * (this.isFacingLeft() ? -1 : 1), 0.0f).RotateBy(angle);
			bullet.setVelocity(vel);
			
			Vec2f offset = Vec2f((this.isFacingLeft() ? -1 : 1) * 16, 0);
			offset.RotateBy(angle);
			bullet.setPosition(this.getPosition() + offset);
			
			bullet.server_SetTimeToDie(-1);
			bullet.server_SetTimeToDie(20.0f);
		}
	}
}

const Vec2f arm_offset = Vec2f(-6, -8);

void onInit(CBlob@ this)
{
	this.Tag("usable by anyone");

	Vehicle_Setup(this,
	              0.0f, // move speed
	              0.1f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              false,  // inventory access
				  RailCannonInfo()
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	Vehicle_AddAmmo(this, v,
	                    90, // fire delay (ticks)
	                    1, // fire bullets amount
	                    1, // fire cost
	                    "mat_lancerod", // bullet ammo config name
	                    "Lance Rods", // name for ammo selection
	                    "railcannonshell", // bullet config name
	                    "RailCannon_Shoot_old", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vec2f(-6.0f, 2.0f) //fire position offset
	);

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "Railcannon_Cannon.png", 80, 16);
	if (arm !is null)
	{
		arm.SetOffset(arm_offset);
	}
	
	this.getShape().SetRotationsAllowed(false);

	string[] autograb = { "mat_lancerod" };
	this.set("autograb blobs", autograb);

	sprite.SetZ(-10.0f);

	this.getCurrentScript().runFlags |= Script::tick_hasattached;

	// auto-load on creation
	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_lancerod");
		if (ammo !is null)
		{
			if (!this.server_PutInInventory(ammo)) ammo.server_Die();
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
				angle = Maths::Max(-50.0f, Maths::Min(angle, 22.0f));
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

		//set the arm angle based on GUNNER mouse aim, see above
		const f32 angle = getAimAngle(this, v);
		v.wep_angle = angle;
		CSprite@ sprite = this.getSprite();
		CSpriteLayer@ arm = sprite.getSpriteLayer("arm");

		if (arm !is null)
		{
			const bool facing_left = sprite.isFacingLeft();
			f32 rotation = angle * (facing_left ? -1 : 1);

			arm.ResetTransform();
			arm.SetFacingLeft(facing_left);
			arm.SetRelativeZ(1.0f);
			arm.SetOffset(arm_offset);
			arm.RotateBy(rotation, Vec2f(facing_left ? -4.0f : 4.0f, 0.0f));
		}

		Vehicle_StandardControls(this, v);
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob, "CARGO");
	}
}
