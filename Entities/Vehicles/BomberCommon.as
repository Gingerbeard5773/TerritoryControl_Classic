#include "VehicleCommon.as";
#include "Hitters.as";
#include "Explosion.as";
#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("aerial");
	this.Tag("vehicle");

	this.SetLight(true);
	this.SetLightRadius(48.0f);
	this.SetLightColor(SColor(255, 255, 240, 171));

	this.set_f32("map dmg modifier", 35.0f);
	this.set_u32("lastDropTime", 0);
	
	this.Tag("invincible attachments"); //set our attached blobs as invincible
	
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	
	this.SetMapEdgeFlags(CBlob::map_collide_up | CBlob::map_collide_sides);
}

void onTick(CBlob@ this)
{
	if (this.getHealth() > 1.0f)
	{
		VehicleInfo@ v;
		if (!this.get("VehicleInfo", @v)) return;

		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSound("BomberLoop.ogg");
		sprite.SetEmitSoundPaused(false);

		Vehicle_BomberControls(this, v);
	}
	else
	{
		this.setAngleDegrees(this.getAngleDegrees() + (this.isFacingLeft() ? 1 : -1));
		if (this.isOnGround() || this.isInWater())
		{
			this.server_DetachAll();
			this.Untag("invincible");
			this.server_SetHealth(-1.0f);
			this.server_Die();
		}
		else
		{
			this.Tag("invincible");
		}
	}
}

void Vehicle_BomberControls(CBlob@ this, VehicleInfo@ v)
{
	AttachmentPoint@ flyer = this.getAttachments().getAttachmentPointByName("FLYER");
	if (flyer is null) return;

	CBlob@ blob = flyer.getOccupied();
	const bool bot = blob !is null && blob.getPlayer() is null;
	
	// get out of seat
	if (isServer() && flyer.isKeyJustPressed(key_up) && blob !is null)
	{
		this.server_DetachFrom(blob);
		return;
	}

	//Bombing
	const bool pressed_key_action3 = bot ? blob.isKeyPressed(key_action3) : flyer.isKeyPressed(key_action3);
	if (pressed_key_action3 && this.get_u32("lastDropTime") < getGameTime())
	{
		CInventory@ inv = this.getInventory();
		if (inv !is null)
		{
			const u32 itemCount = inv.getItemsCount();
			
			if (isClient())
			{
				if (itemCount > 0)
				{ 
					this.getSprite().PlaySound("bridge_open", 1.0f, 1.0f);
				}
				else if (blob.isMyPlayer())
				{
					Sound::Play("NoAmmo");
				}
			}

			if (itemCount > 0)
			{
				if (isServer())
				{
					CBlob@ item = inv.getItem(0);
					const u32 quantity = item.getQuantity();

					if (item.hasTag("explosive") && quantity <= 8)
					{
						CBlob@ bomb = server_CreateBlob(item.getName(), this.getTeamNum(), this.getPosition());
						bomb.server_SetQuantity(1);
						bomb.SetDamageOwnerPlayer(blob.getPlayer());
						bomb.Tag("no pickup");
						bomb.set_u8("bomber team", this.getTeamNum());
						this.IgnoreCollisionWhileOverlapped(bomb);
						
						if (quantity > 0)
						{
							item.server_SetQuantity(quantity - 1);
						}
						if (item.getQuantity() == 0)
						{
							item.server_Die();
						}
					}
					else
					{
						this.server_PutOutInventory(item);
						item.setPosition(this.getPosition());
					}
				}
			}
			this.set_u32("lastDropTime", getGameTime() + 30);
		}
	}

	//Handling
	const Vec2f vel = this.getVelocity();
	const f32 moveForce = v.move_speed;
	const f32 turnSpeed = v.turn_speed;

	Vec2f force;
	bool up = bot ? blob.isKeyPressed(key_action1) : flyer.isKeyPressed(key_action1);
	bool down = bot ? blob.isKeyPressed(key_action2) && getGameTime() % 3 == 0 : flyer.isKeyPressed(key_action2);
	bool left = bot ? blob.isKeyPressed(key_left) : flyer.isKeyPressed(key_left);
	bool right = bot ? blob.isKeyPressed(key_right) : flyer.isKeyPressed(key_right);
	const bool fakeCrash = blob is null && !this.isOnGround() && !this.isInWater();

	if (fakeCrash)
	{
		up = false;
		down = true;
		if (Maths::Abs(vel.x) >= 0.5f)
		{
			left = vel.x < 0.0f ? true : false;
			right = vel.x < 0.0f ? false : true;
		}
	}
	
	CSprite@ sprite = this.getSprite();
	const f32 volume = Maths::Clamp(Maths::Lerp(sprite.getEmitSoundVolume(), up ? 1.0f : (down ? 0.0f : (this.isOnGround() ? 0.0f : 0.15f)), (1.0f / 30) * 2.5f), 0.0f, 1.0f);
	sprite.SetEmitSoundVolume(volume);
	
	const f32 goalSpeed = fakeCrash ? -300.0f : ((up ? 35.0f : 0.0f) + (down ? 220.75f : 310.15f));
	force.y = Maths::Lerp(this.get_f32("fly_amount"), goalSpeed, (1.0f / getTicksASecond()) * (fakeCrash ? 0.2f : 1.0f));
	this.set_f32("fly_amount", force.y);

	if (left)
	{
		force.x -= moveForce;
		if (vel.x < -turnSpeed)
		{
			this.SetFacingLeft(true);
		}
	}
	if (right)
	{
		force.x += moveForce;
		if (vel.x > turnSpeed)
		{
			this.SetFacingLeft(false);
		}
	}
	if (fakeCrash)
	{
		if (Maths::Abs(vel.x) >= 0.5f)
		{
			force.x *= 1.1f;
		}
	}
	this.AddForce(Vec2f(force.x, -force.y));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid, Vec2f normal, Vec2f point1)
{
	const f32 power = this.getOldVelocity().getLength();
	if (power <= 2.0f) return;
	
	if (!solid) return;

	if (isClient())
	{
		Sound::Play("WoodHeavyHit1.ogg", this.getPosition(), 1.0f);
	}

	this.server_Hit(this, point1, normal, this.getAttachments().getAttachmentPointByName("FLYER") is null ? power * 0.6f : power * 0.25f, 0, true);
}

void onDie(CBlob@ this)
{
	Sound::Play("WoodDestruct.ogg", this.getPosition(), 1.0f);
	DoExplosion(this);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getTeamNum() == this.getTeamNum() && canSeeButtons(this, forBlob);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	//explode all bombs we dropped from inventory cuz of death
	if (this.getHealth() <= 0.0f && blob.hasTag("explosive"))
	{
		blob.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), blob.getInitialHealth() + 1.0f, Hitters::explosion, true);
	}
}

void DoExplosion(CBlob@ this)
{
	Sound::Play("KegExplosion.ogg", this.getPosition(), 1.0f);
	this.set_Vec2f("explosion_offset", Vec2f(0, -16).RotateBy(this.getAngleDegrees()));
	
	Explode(this, 32.0f, 3.0f);
	Random rand(this.getNetworkID());
	for (u8 i = 0; i < 16; i++)
	{
		Vec2f dir = Vec2f(1 - i / 2.0f, -1 + i / 2.0f);
		Vec2f jitter = Vec2f((int(rand.NextRanged(200)) - 100) / 200.0f,(int(rand.NextRanged(200)) - 100) / 200.0f);
		
		LinearExplosion(this, Vec2f(dir.x * jitter.x, dir.y * jitter.y), 16.0f + rand.NextRanged(16), 10.0f, 4, 5.0f, Hitters::explosion);
	}
	this.getSprite().Gib();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (!blob.isCollidable() || blob.isAttached()) return false;

	if (blob.getShape().isStatic()) return true;
	
	if (blob.getTeamNum() != this.getTeamNum())
	{
		if (blob.hasTag("player") && this.getShape().vellen > 1.0f) return true;

		if (blob.hasTag("aerial") || blob.hasTag("projectile")) return true;
	}

	return false;
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{	
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	// jump out
	if (detached.hasTag("player") && attachedPoint.socket)
	{
		detached.setPosition(detached.getPosition() + Vec2f(0.0f, -4.0f));
		detached.setVelocity(this.getVelocity() + v.out_vel);
		detached.IgnoreCollisionWhileOverlapped(null);
		this.IgnoreCollisionWhileOverlapped(null);
	}
}
