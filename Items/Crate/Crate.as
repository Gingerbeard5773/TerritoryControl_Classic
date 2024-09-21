// generic crate
// can hold items in inventory or unpacks to catapult/ship etc.

#include "CrateCommon.as"
#include "VehicleAttachmentCommon.as"
#include "Help.as"
#include "Hitters.as"
#include "GenericButtonCommon.as"
#include "KnockedCommon.as"
#include "ActivationThrowCommon.as"

// crate tags and their uses

// "parachute"      : this uses a parachute
// "unpackall"       : this can unpack even if there is no "packed" blob
// "unpack on land"    : this unpacks when touching ground
// "destroy on touch"   : this dies when touching ground
// "unpack_only_water"   : this can only unpack in water
// "unpack_check_nobuild" : this can only unpack if block-type blobs arent in the way

/// TERRITORY CONTROL
/// "plasteel crate" : plasteel flavoured crate
/// "packer crate"   : packer flavoured crate. dies on throw and when nothing is left in the inventory.

//proportion of distance allowed (1.0f == overlapping radius, 2.0f = within 1 extra radius)
const f32 ally_allowed_distance = 2.0f;

//time it takes to unpack the crate
const u32 unpackSecs = 3;

Crate@[] presets = 
{
	Crate("mortar",              3,   Vec2f(2, 2)),
	Crate("steamtank",           7,   Vec2f(5, 3)),
	Crate("gatlinggun",          11,  Vec2f(2, 2)),
	Crate("howitzer",            12,  Vec2f(2, 2)),
	Crate("bomber",              13,  Vec2f(5, 3)),
	Crate("armoredbomber",       13,  Vec2f(5, 3)),
	Crate("rocketlauncher",      0,   Vec2f(2, 2)),
	Crate("car",                 0,   Vec2f(4, 2)),
	Crate("scyther",             0,   Vec2f(3, 3), 0, "plasteel crate"),
	Crate("molecularfabricator", 0,   Vec2f(4, 2), 0, "plasteel crate"),

	Crate("longboat",    1,   Vec2f(9, 4),  0, "unpack_only_water"),
	Crate("warboat",     2,   Vec2f(9, 6),  0, "unpack_only_water"),
	Crate("catapult",    4,   Vec2f(5, 3)),
	Crate("ballista",    5,   Vec2f(5, 5)),
	Crate("mounted_bow", 6,   Vec2f(3, 3)),
	Crate("outpost",     15,  Vec2f(5, 5), 50, "unpack_check_nobuild")
};

void onInit(CBlob@ this)
{
	this.checkInventoryAccessibleCarefully = true;

	this.Tag("activatable");

	this.addCommandID("unpack");
	this.addCommandID("unpack_client"); // just sets the drag...
	this.addCommandID("stop unpack");

	Activate@ func = @onActivate;
	this.set("activate handle", @func);

	const string packed = this.exists("packed") ? this.get_string("packed") : "";
	if (!packed.isEmpty())
	{
		UseCratePreset(this, packed, presets);
	}

	if (this.hasTag("plasteel crate"))
	{
		this.getSprite().SetAnimation("plasteel");
	}
	else if (this.hasTag("packer crate"))
	{
		this.getSprite().SetAnimation("packer_crate");
	}
	else if (this.exists("frame") && !packed.isEmpty())
	{
		const u8 frame = this.get_u8("frame");

		CSpriteLayer@ icon = this.getSprite().addSpriteLayer("icon", "/MiniIcons.png", 16, 16, this.getTeamNum(), -1);
		if (icon !is null)
		{
			Animation@ anim = icon.addAnimation("display", 0, false);
			anim.AddFrame(frame);
			icon.SetOffset(Vec2f(-2, 1));
			icon.SetRelativeZ(1);
		}
		this.getSprite().SetAnimation("label");

		// help
		const string iconToken = "$crate_" + packed + "$";
		AddIconToken(iconToken, "/MiniIcons.png", Vec2f(16, 16), frame);
		SetHelp(this, "help use", "", iconToken + getTranslatedString("Unpack {ITEM}   $KEY_E$").replace("{ITEM}", packed), "", 4);
	}
	else
	{
		this.Tag("dont deactivate");
	}
	// Kinda hacky, only normal crates ^ with "dont deactivate" will ignore "activated"
	this.Tag("activated");

	this.set_u32("unpack secs", unpackSecs);
	this.set_u32("unpack time", 0);

	if (this.exists("packed name"))
	{
		const string name = getTranslatedString(this.get_string("packed name"));
		if (name.length > 1)
			this.setInventoryName("Crate with " + name);
	}

	if (!this.exists("required space"))
	{
		this.set_Vec2f("required space", Vec2f(5, 4));
	}
	
	if (!this.exists("gold building amount"))
	{
		this.set_s32("gold building amount", 0);
	}

	this.getSprite().SetZ(-10.0f);
}

bool UseCratePreset(CBlob@ this, const string &in packed, Crate@[] presets)
{
	for (int i = 0; i < presets.length; i++)
	{
		Crate@ preset = presets[i];
		if (preset.name != packed) continue;

		this.set_u8("frame", preset.frame);
		this.set_Vec2f("required space", preset.space);
		this.set_s32("gold building amount", preset.gold);

		for (int i = 0; i < preset.tags.length; i++)
		{
			this.Tag(preset.tags[i]);
		}

		return true;
	}
	return false;
}

void onTick(CBlob@ this)
{
	// parachute

	if (this.hasTag("parachute"))		// wont work with the tick frequency
	{
		if (this.getSprite().getSpriteLayer("parachute") is null)
		{
			ShowParachute(this);
		}

		// para force + swing in wind
		this.AddForce(Vec2f(Maths::Sin(getGameTime() * 0.03f) * 1.0f, -30.0f * this.getVelocity().y));

		if (this.isOnGround() || this.isInWater() || this.isAttached())
		{
			Land(this);
		}
	}
	else
	{
		if (hasSomethingPacked(this))
			this.getCurrentScript().tickFrequency = 15;
		else
		{
			this.getCurrentScript().tickFrequency = 0;
			return;
		}

		// can't unpack in no build sector or blocked in with walls!
		if (!canUnpackHere(this))
		{
			this.set_u32("unpack time", 0);
			this.getCurrentScript().tickFrequency = 15;
			this.getShape().setDrag(2.0);
			return;
		}

		const u32 unpackTime = this.get_u32("unpack time");
		if (unpackTime != 0 && getGameTime() >= unpackTime)
		{
			Unpack(this);
			return;
		}
	}
}

void Land(CBlob@ this)
{
	this.Untag("parachute");
	HideParachute(this);

	// unpack immediately
	if (this.exists("packed") && this.hasTag("unpack on land"))
	{
		Unpack(this);
	}

	if (this.hasTag("destroy on touch"))
	{
		this.server_Die();
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	if (this.getName() == blob.getName() && !blob.hasTag("parachute")) return true;

	return blob.getShape().isStatic() || blob.hasTag("player") || blob.hasTag("projectile");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return (this.getTeamNum() == byBlob.getTeamNum() || this.isOverlapping(byBlob));
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	if (this.hasTag("unpackall") || !canSeeButtons(this, forBlob))
		return false;
		
	if (hasSomethingPacked(this))
	{
		return false;
	}

	if (forBlob.getCarriedBlob() !is null
		&& this.getInventory().canPutItem(forBlob.getCarriedBlob()))
	{
		return true; // OK to put an item in whenever
	}

	if (this.getTeamNum() == forBlob.getTeamNum())
	{
		const f32 dist = (this.getPosition() - forBlob.getPosition()).Length();
		const f32 rad = (this.getRadius() + forBlob.getRadius());

		if (dist < rad * ally_allowed_distance)
		{
			return true; // Allies can access from further away
		}
	}
	else if (this.isOverlapping(forBlob))
	{
		return true; // Enemies can access when touching
	}

	return false;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!canSeeButtons(this, caller)) return;

	Vec2f buttonpos(0, 0);

	if (this.hasTag("unpackall"))
	{
		caller.CreateGenericButton(12, buttonpos, this, this.getCommandID("unpack"), getTranslatedString("Unpack all"));
	}
	else if (hasSomethingPacked(this) && !canUnpackHere(this))
	{
		const string msg = getTranslatedString("Can't unpack {ITEM} here").replace("{ITEM}", getTranslatedString(this.get_string("packed name")));
		CButton@ button = caller.CreateGenericButton(12, buttonpos, this, 0, msg);
		if (button !is null)
		{
			button.SetEnabled(false);
		}
	}
	else if (isUnpacking(this))
	{		
		string text = getTranslatedString("Stop {ITEM}").replace("{ITEM}", getTranslatedString(this.get_string("packed name")));
		CButton@ button = caller.CreateGenericButton("$DISABLED$", buttonpos, this, this.getCommandID("stop unpack"), text);
		
		button.enableRadius = 20.0f;
	}
	else if (hasSomethingPacked(this))
	{
		string text = getTranslatedString("Unpack {ITEM}").replace("{ITEM}", getTranslatedString(this.get_string("packed name")));
		CButton@ button = caller.CreateGenericButton(12, buttonpos, this, this.getCommandID("unpack"), text);
		
		button.enableRadius = 20.0f;
	}
}

void onActivate(CBitStream@ params)
{
	if (!isServer()) return;

	u16 this_id;
	if (!params.saferead_u16(this_id)) return;

	CBlob@ this = getBlobByNetworkID(this_id);
	if (this is null) return;
		
	u16 caller_id;
	if (!params.saferead_u16(caller_id)) return;

	CBlob@ caller = getBlobByNetworkID(caller_id);
	if (caller is null) return;

	DumpOutItems(this, 5.0f, caller.getVelocity());
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("unpack") && isServer())
	{
		if (hasSomethingPacked(this))
		{
			if (canUnpackHere(this))
			{
				CPlayer@ p = getNet().getActiveCommandPlayer();
				if (p is null) return;
					
				CBlob@ caller = p.getBlob();
				if (caller is null) return;

				// range check
				if (this.getDistanceTo(caller) > 32.0f) return;

				this.server_setTeamNum(caller.getTeamNum());

				this.set_u32("unpack time", getGameTime() + this.get_u32("unpack secs") * getTicksASecond());
				this.Sync("unpack time", true);

				this.getShape().setDrag(10.0f);

				this.SendCommand(this.getCommandID("unpack_client"));
			}
		}
		else
		{
			this.server_SetHealth(-1.0f);
			this.server_Die();
		}
	}
	else if (cmd == this.getCommandID("unpack_client") && isClient())
	{
		this.getShape().setDrag(10.0f);
	}
	else if (cmd == this.getCommandID("stop unpack") && isServer())
	{
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ caller = p.getBlob();
		if (caller is null) return;

		if (this.getDistanceTo(caller) > 32.0f) return;

		this.set_u32("unpack time", 0);
		this.Sync("unpack time", true);
	}
}

void Unpack(CBlob@ this)
{
	if (!isServer() || this.hasTag("unpacked")) return;
	
	CMap@ map = getMap();
	Vec2f space = this.get_Vec2f("required space");
	Vec2f offsetPos = crate_getOffsetPos(this, map);
	Vec2f center = offsetPos + space * map.tilesize * 0.5f;

	CBlob@ blob = server_CreateBlob(this.get_string("packed"), this.getTeamNum(), center);
	if (blob !is null)
	{
		// attach to VEHICLE attachment if possible
		TryToAttachVehicle(blob);

		// msg back factory so it can add this item
		if (this.exists("msg blob"))
		{
			CBitStream params;
			params.write_u16(blob.getNetworkID());
			CBlob@ factory = getBlobByNetworkID(this.get_u16("msg blob"));
			if (factory !is null)
			{
				factory.SendCommand(factory.getCommandID("track blob"), params);
			}
		}

		blob.SetFacingLeft(this.isFacingLeft());
	}

	this.Tag("unpacked");
	this.set_s32("gold building amount", 0); // for crates with vehicles that cost gold
	this.server_SetHealth(-1.0f); // TODO: wont gib on client
	this.server_Die();
}

bool isUnpacking(CBlob@ this)
{
	return getGameTime() <= this.get_u32("unpack time");
}

void ShowParachute(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ parachute = sprite.addSpriteLayer("parachute", 32, 32);
	if (parachute !is null)
	{
		Animation@ anim = parachute.addAnimation("default", 0, true);
		anim.AddFrame(4);
		parachute.SetOffset(Vec2f(0.0f, - 17.0f));
	}
}

void HideParachute(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	CSpriteLayer@ parachute = sprite.getSpriteLayer("parachute");
	if (parachute !is null && parachute.isVisible())
	{
		parachute.SetVisible(false);
		ParticlesFromSprite(parachute);
	}
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	this.getSprite().PlaySound("thud.ogg");
}

void onDie(CBlob@ this)
{
	HideParachute(this);
	this.getSprite().Gib();
	Vec2f pos = this.getPosition();
	Vec2f vel = this.getVelocity();

	//custom gibs
	for (int i = 0; i < 4; i++)
	{
		CParticle@ temp = makeGibParticle("Crate.png", pos, vel + getRandomVelocity(90, 1 , 120), 9, 2 + i, Vec2f(16, 16), 2.0f, 20, "Sounds/material_drop.ogg", 0);
	}
}

bool canUnpackHere(CBlob@ this)
{
	CMap@ map = getMap();
	Vec2f pos = this.getPosition();

	Vec2f space = this.get_Vec2f("required space");
	Vec2f offsetPos = crate_getOffsetPos(this, map);
	for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
	{
		for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
		{
			Vec2f temp = (Vec2f(step_x + 0.5, step_y + 0.5) * map.tilesize);
			Vec2f v = offsetPos + temp;
			if (v.y < map.tilesize || map.isTileSolid(v))
			{
				return false;
			}
		}
	}

	//no unpacking at map ceiling
	if (pos.y + 4 < (space.y + 2) * map.tilesize)
	{
		return false;
	}

	const bool water = this.hasTag("unpack_only_water");
	bool inwater = this.isInWater() || map.isInWater(pos + Vec2f(0.0f, map.tilesize));
	if (this.isAttached())
	{
		CBlob@ parent = this.getAttachments().getAttachmentPointByName("PICKUP").getOccupied();
		if (parent !is null)
		{
			inwater = parent.isInWater() || map.isInWater(parent.getPosition() + Vec2f(0.0f, parent.getRadius()));
			return ((!water && parent.isOnGround()) || (water && inwater));
		}
	}
	const bool supported = ((!water && this.isOnGround()) || (water && inwater));
	return (supported);
}

Vec2f crate_getOffsetPos(CBlob@ blob, CMap@ map)
{
	Vec2f space = blob.get_Vec2f("required space");
	space.x *= 0.5f;
	space.y -= 1;
	Vec2f offsetPos = map.getAlignedWorldPos(blob.getPosition() + Vec2f(4, 6) - space * map.tilesize);
	return offsetPos;
}

bool DumpOutItems(CBlob@ this, f32 pop_out_speed = 5.0f, Vec2f init_velocity = Vec2f_zero)
{
	bool dumped_anything = false;
	if (isClient())
	{
		if (this.getInventory().getItemsCount() > 0)
		{
			this.getSprite().PlaySound("give.ogg");
		}
	}
	if (isServer())
	{
		Vec2f velocity = (init_velocity == Vec2f_zero) ? this.getOldVelocity() : init_velocity;
		CInventory@ inv = this.getInventory();
		u8 target_items_left = 0;
		u8 item_num = 0;

		while (inv !is null && (inv.getItemsCount() > target_items_left))
		{
			CBlob@ item = inv.getItem(item_num);

			dumped_anything = true;
			this.server_PutOutInventory(item);
			if (pop_out_speed == 0)
			{
				item.setVelocity(velocity);
			}
			else
			{
				const f32 magnitude = (1 - XORRandom(3) * 0.25) * pop_out_speed;
				item.setVelocity(velocity + getRandomVelocity(90, magnitude, 45));
			}
		}
	}
	return dumped_anything;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob !is null ? !blob.isCollidable() : !solid) return;

	if (isServer() && this.getOldVelocity().Length() > 5.0f)
	{
		if (hasSomethingPacked(this))
		{
			Unpack(this);
		}
		else if (this.hasTag("packer crate"))
		{
			this.server_Die();
		}
	}
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("packer crate") && this.getInventory().getItemsCount() == 0)
	{
		this.server_Die();
	}
}


// SPRITE

// render unpacking time

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (!hasSomethingPacked(blob)) return;
	
	Vec2f pos2d = blob.getScreenPos();
	const u32 gameTime = getGameTime();
	const u32 unpackTime = blob.get_u32("unpack time");

	if (unpackTime > gameTime)
	{
		// draw drop time progress bar
		const int top = pos2d.y - 1.0f * blob.getHeight();
		Vec2f dim(32.0f, 12.0f);
		const int secs = 1 + (unpackTime - gameTime) / getTicksASecond();
		Vec2f upperleft(pos2d.x - dim.x / 2, top - dim.y - dim.y);
		Vec2f lowerright(pos2d.x + dim.x / 2, top - dim.y);
		const f32 progress = 1.0f - (f32(secs) / f32(blob.get_u32("unpack secs")));
		GUI::DrawProgressBar(upperleft, lowerright, progress);
	}

	if (blob.isAttached())
	{
		AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		if (holder is null || !holder.isMyPlayer()) return;

		CMap@ map = getMap();

		Vec2f space = blob.get_Vec2f("required space");
		Vec2f offsetPos = crate_getOffsetPos(blob, map);
		Vec2f aligned = getDriver().getScreenPosFromWorldPos(offsetPos);

		const f32 scalex = getDriver().getResolutionScaleFactor();
		const f32 zoom = getCamera().targetDistance * scalex;

		DrawSlots(space, aligned, zoom);

		for (f32 step_x = 0.0f; step_x < space.x ; ++step_x)
		{
			for (f32 step_y = 0.0f; step_y < space.y ; ++step_y)
			{
				Vec2f temp = (Vec2f(step_x + 0.5, step_y + 0.5) * map.tilesize);
				Vec2f v = offsetPos + temp;
			
				if (map.isTileSolid(v))
				{
					GUI::DrawIcon("CrateSlots.png", 5, Vec2f(8, 8), aligned + (temp - Vec2f(0.5f, 0.5f)* map.tilesize) * 2 * zoom, zoom);
				}
			}
		}
	}
}

void DrawSlots(Vec2f size, Vec2f pos, const f32 zoom)
{
	const int x = Maths::Floor(size.x);
	const int y = Maths::Floor(size.y);
	CMap@ map = getMap();

	GUI::DrawRectangle(pos, pos + Vec2f(x, y) * map.tilesize * zoom * 2, SColor(125, 255, 255, 255));
	GUI::DrawLine2D(pos + Vec2f(0, 0) * map.tilesize * zoom * 2, pos + Vec2f(x, 0) * map.tilesize * zoom * 2, SColor(255, 255, 255, 255));
	GUI::DrawLine2D(pos + Vec2f(x, 0) * map.tilesize * zoom * 2, pos + Vec2f(x, y) * map.tilesize * zoom * 2, SColor(255, 255, 255, 255));
	GUI::DrawLine2D(pos + Vec2f(x, y) * map.tilesize * zoom * 2, pos + Vec2f(0, y) * map.tilesize * zoom * 2, SColor(255, 255, 255, 255));
	GUI::DrawLine2D(pos + Vec2f(0, y) * map.tilesize * zoom * 2, pos + Vec2f(0, 0) * map.tilesize * zoom * 2, SColor(255, 255, 255, 255));
}
