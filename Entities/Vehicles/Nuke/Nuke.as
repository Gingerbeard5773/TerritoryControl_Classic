#include "VehicleCommon.as";
#include "VehicleAttachmentCommon.as";
#include "Hitters.as";
#include "HittersTC.as";

const u32 detonate_seconds = 30;

void onInit(CBlob@ this)
{
	Vehicle_Setup(this,
	              125, // move speed
	              0.20f,  // turn speed
	              Vec2f(0.0f, 0.0f), // jump out velocity
	              true  // inventory access
	             );
	VehicleInfo@ v;
	if (!this.get("VehicleInfo", @v)) return;

	this.getShape().SetOffset(Vec2f(0, 8));

	Vehicle_SetupGroundSound(this, v, "WoodenWheelsRolling", 1.0f, 1.0f);
	Vehicle_addWheel(this, v, "Wheel.png", 16, 16, 0, Vec2f(-5.0f, 14.0f));
	Vehicle_addWheel(this, v, "Wheel.png", 16, 16, 0, Vec2f(8.0f, 14.0f));

	this.getShape().SetRotationsAllowed(true);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;

	this.SetLight(true);
	this.SetLightColor(SColor(255, 255, 0, 0));
	this.SetLightRadius(128.5f);
	
	this.addCommandID("nuke_activate_sv");
	this.addCommandID("nuke_activate_cl");
	this.addCommandID("nuke_ready_sv");
	this.addCommandID("nuke_ready_cl");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.isAttached()) return;
	
	if (this.hasTag("nuke_active")) return;
	
	if (!this.get_bool("nuke_ready"))
	{
		CPlayer@ owner = this.getDamageOwnerPlayer();
		CPlayer@ ply = caller.getPlayer();

		bool canArmNuke = true;
		string description = "Arm the R.O.F.L.!";
		if (owner !is null)
		{
			description += "\n(Only by "+owner.getUsername()+")";
			canArmNuke = ply !is null && ply.getUsername() == owner.getUsername();
		}
		CButton@ btn_ready = caller.CreateGenericButton(11, Vec2f(0, 3), this, this.getCommandID("nuke_ready_sv"), description);
		btn_ready.SetEnabled(canArmNuke);
	}
	else
	{
		CButton@ btn_detonate = caller.CreateGenericButton(11, Vec2f(0, 3), this, this.getCommandID("nuke_activate_sv"), "Set off the R.O.F.L.!");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("nuke_ready_sv") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null || this.isAttached()) return;

		this.SetDamageOwnerPlayer(player);
	
		this.set_bool("nuke_ready", true);
		this.SendCommand(this.getCommandID("nuke_ready_cl"));
	}
	else if (cmd == this.getCommandID("nuke_ready_cl") && isClient())
	{
		this.set_bool("nuke_ready", true);
	}
	else if (cmd == this.getCommandID("nuke_activate_sv") && isServer())
	{
		if (this.isAttached()) return;

		if (!this.get_bool("nuke_ready") || this.hasTag("nuke_active")) return;
	
		CPlayer@ owner = this.getDamageOwnerPlayer();
		if (owner is null ? false : !this.get_bool("nuke_ready")) return;
	
		this.set_u32("nuke_boomtime", getGameTime() + detonate_seconds * 30);
		this.Tag("nuke_active");
	
		this.SendCommand(this.getCommandID("nuke_activate_cl"));
	}
	else if (cmd == this.getCommandID("nuke_activate_cl") && isClient())
	{
		if (!this.get_bool("nuke_ready")) return;
	
		this.set_u32("nuke_boomtime", getGameTime() + detonate_seconds * 30);
		this.Tag("nuke_active");
	}
}

void onTick(CBlob@ this)
{
	if (this.hasTag("nuke_active") && !this.hasTag("dead"))
	{
		const u32 time = getGameTime();
		
		if (isServer())
		{
			if (time > this.get_u32("nuke_boomtime"))
			{
				CBlob@ blob = server_CreateBlob("nukeexplosion", this.getTeamNum(), this.getPosition());
				blob.SetDamageOwnerPlayer(this.getDamageOwnerPlayer());
				this.server_Die();
				this.Tag("dead");
			}
		}
	
		if (isClient() && !this.hasTag("nuke_alarm"))
		{
			if (time % 85 == 0)
			{
				// Emit sound is used by the Vehicle.as :(
				this.getSprite().PlaySound("Nuke_Loop.ogg", 0.75f, 1.00f);
			}
			
			if (time > (this.get_u32("nuke_boomtime") - 90))
			{
				this.getSprite().PlaySound("Nuke_Alarm.ogg", 1.00f, 1.00f);
				this.Tag("nuke_alarm");
			}
		}
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!blob.hasTag("nuke_active") || blob.hasTag("dead")) return;

	const u32 secs = ((blob.get_u32("nuke_boomtime") - 1 - getGameTime()) / getTicksASecond()) + 1;
	const string units = ((secs != 1) ? "seconds" : "second");
	const string text = "Detonation in " + secs + " " + units + "!";
	
	Vec2f pos = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(0, 22));
	GUI::SetFont("menu");
	GUI::DrawTranslatedTextCentered(text, pos, SColor(255, 255, 0, 0));
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null && !this.hasTag("nuke_active"))
	{
		TryToAttachVehicle(this, blob, "CARGO");
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasTag("nuke_active") && byBlob.hasTag("vehicle") && this.getTeamNum() == byBlob.getTeamNum();
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	return blob.hasTag("vehicle") ? this.getTeamNum() != blob.getTeamNum() : true;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch (customData)
	{
		case HittersTC::bullet:
			damage *= 0.5f;
			break;
	}
	return damage;
}
