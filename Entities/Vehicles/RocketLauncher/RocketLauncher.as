#include "VehicleCommon.as";
#include "Hitters.as";
#include "TC_Translation.as";

// Rocket Launcher Logic

const Vec2f arm_offset = Vec2f(-4, -2);

class RocketLauncherInfo : VehicleInfo
{
	void onFire(CBlob@ this, CBlob@ bullet, const u16 &in fired_charge)
	{
		if (bullet !is null)
		{
			const f32 sign = this.isFacingLeft() ? -1 : 1;
			const f32 angle = wep_angle * sign;
			Vec2f startPos = this.getPosition() + Vec2f(sign * 16, -3).RotateBy(angle);

			bullet.setPosition(startPos);
			bullet.set_f32("velocity", 15.0f);
			bullet.setAngleDegrees(angle + 90 + (this.isFacingLeft() ? 180 : 0));
			bullet.IgnoreCollisionWhileOverlapped(this);
			bullet.server_setTeamNum(this.getTeamNum());
			
			if (isClient())
			{
				Vec2f dir = Vec2f(sign, 0.0f).RotateBy(angle);
				for (int i = 1; i < 5; i++)
				{
					MakeParticle(this, -dir * i, "SmallExplosion");
				}
				//this.getSprite().PlaySound("KegExplosion", 1.0f, 0.8f);
			}
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
	              RocketLauncherInfo()
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;
	
	Vehicle_AddAmmo(this, v,
	                    8, // fire delay (ticks)
	                    1, // fire bullets amount
	                    1, // fire cost
	                    "mat_smallrocket", // bullet ammo config name
	                    name(Translate::SmallRocket), // name for ammo selection
	                    "smallrocket", // bullet config name
	                    "KegExplosion", // fire sound
	                    "EmptyFire", // empty fire sound
	                    Vec2f(-6.0f, 2.0f) //fire position offset
	);

	this.setInventoryName(name(Translate::RocketLauncher));

	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ arm = sprite.addSpriteLayer("arm", "RocketLauncher_Cannon.png", 16, 16);
	if (arm !is null)
	{
		arm.SetOffset(arm_offset);
		arm.SetRelativeZ(17.5f);
	}

	this.getShape().SetRotationsAllowed(false);
	
	string[] autograb = { "mat_smallrocket" };
	this.set("autograb blobs", autograb);
	
	sprite.SetZ(-10.0f);
	
	this.getCurrentScript().runFlags |= Script::tick_hasattached;

	if (isServer())
	{
		CBlob@ ammo = server_CreateBlob("mat_smallrocket");
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
		gunner.offsetZ = 5.0f;
		CBlob@ operator = gunner.getOccupied();
		Vec2f aimpos = operator.getPlayer() is null ? operator.getAimPos() : gunner.getAimPos();
		Vec2f aim_vec = gunner.getPosition() - aimpos;

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
			arm.RotateBy(rotation, Vec2f(4.0f * sign, 0.0f));
		}
		Vehicle_LauncherControls(this, v);
	}
}

void Vehicle_LauncherControls(CBlob@ this, VehicleInfo@ v)
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

	const bool bot = caller.getPlayer() is null;
	const bool press_action_1 = bot ? caller.isKeyPressed(key_action1) : ap.isKeyPressed(key_action1);
	if (press_action_1 && getGameTime() > v.fire_time)
	{
		CBitStream bt;
		bt.write_u16(caller.getNetworkID());
		bt.write_u16(v.charge);
		this.SendCommand(this.getCommandID("fire client"), bt);

		Fire(this, v, caller, v.charge);
	}
}

void MakeParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam")
{
	if (!isClient()) return;

	Vec2f offset = Vec2f(8, 0).RotateBy(this.getAngleDegrees());
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + offset, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null)
	{
		TryToAttachVehicle(this, blob);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return blob.isCollidable() && blob.getShape().isStatic();
}
