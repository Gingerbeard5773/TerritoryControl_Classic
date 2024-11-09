#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::SmokeGrenade));
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action3);
	}

	this.addCommandID("client_activate");
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	if (this.isAttached() && !this.hasTag("activated"))
	{
		AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
		if (ap !is null && ap.isKeyJustPressed(key_action3) && ap.getOccupied() !is null && !ap.getOccupied().isAttached())
		{
			this.server_SetTimeToDie(20);
			this.Tag("activated");
			this.getCurrentScript().tickFrequency = 8;
			this.SendCommand(this.getCommandID("client_activate"));
		}
	}

	if (this.hasTag("activated"))
	{
		server_CreateBlob("smokegas", -1, this.getPosition());
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client_activate") && isClient())
	{
		this.Tag("activated");
		CSprite@ sprite = this.getSprite();
		sprite.SetEmitSoundPaused(false);
	}
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
	//special logic colliding with players
	if (blob.hasTag("player"))
	{
		//collide with shielded enemies
		return (blob.getTeamNum() != this.getTeamNum() && blob.hasTag("shielded"));
	}

	return blob.isCollidable();
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (!solid) return;

	const f32 vellen = this.getOldVelocity().Length();
	if (vellen > 1.7f)
	{
		Sound::Play("/BombBounce.ogg", this.getPosition(), Maths::Min(vellen / 8.0f, 1.1f), 1.2f);
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();
	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

///SPRITE

void onInit(CSprite@ this)
{
	this.SetEmitSound("/SmokeGrenadeFizz.ogg");
	this.SetEmitSoundPaused(true);
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob.hasTag("activated"))
	{
		this.RotateAllBy(5 * blob.getVelocity().x, Vec2f_zero);
	}
}
