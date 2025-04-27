#include "Hitters.as";
#include "TreeCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getShape().SetRotationsAllowed(false);
	this.Tag("place norotate");
	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 45;

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Treecapicator_Idle.ogg");
	sprite.SetEmitSoundVolume(0.2f);
	sprite.SetEmitSoundSpeed(0.8f);
	sprite.SetEmitSoundPaused(true);
	
	this.set_bool("isActive", false);
	this.addCommandID("cl_toggle");
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	if (!this.getShape().isStatic()) return;

	if (!this.getInventory().isFull())
	{
		Vec2f pos = this.getPosition();
		CBlob@[] blobs;
		getMap().getBlobsInBox(pos + Vec2f(-7.0f, 0.0f), pos + Vec2f(7.0f, 0.0f), @blobs);
		
		for (int i = 0; i < blobs.length; i++)
		{
			CBlob@ b = blobs[i];
			if (!canHit(b)) continue;

			if (this.get_bool("isActive"))
			{
				if (b.hasTag("tree"))
				{
					TreeVars@ tree;
					b.get("TreeVars", @tree);
					if (tree !is null && tree.height == tree.max_height)
					{
						this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 1.00f, Hitters::saw);
					}
				}
				else if (b.getName() == "log")
				{
					this.server_PutInInventory(b);
				}
				else if (/*b.hasTag("flesh") ||*/ b.hasTag("scenary"))
				{
					this.server_Hit(b, b.getPosition(), Vec2f(0, 0), 2.00f, Hitters::sword);
				}

				return;
			}

			this.getCurrentScript().tickFrequency = 15;
			this.set_bool("isActive", true);

			CBitStream stream;
			stream.write_bool(true);
			this.SendCommand(this.getCommandID("cl_toggle"), stream);

			return;
		}
	}

	if (this.get_bool("isActive"))
	{
		this.getCurrentScript().tickFrequency = 45;
		this.set_bool("isActive", false);

		CBitStream stream;
		stream.write_bool(false);
		this.SendCommand(this.getCommandID("cl_toggle"), stream);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("cl_toggle") && isClient())
	{
		const bool active = params.read_bool();
		this.set_bool("isActive", active);

		CSprite@ sprite = this.getSprite();
		sprite.PlaySound("LeverToggle.ogg", 0.6f);
		sprite.SetEmitSoundPaused(!active);
		sprite.SetAnimation(active ? "on" : "off");
	}
}

bool canHit(CBlob@ b)
{
	if (b.hasTag("tree"))
	{
		TreeVars@ tree;
		b.get("TreeVars", @tree);
		if (tree !is null && tree.height == tree.max_height)
		{
			return true;
		}
	}
	
	return b.getName() == "log" || /*b.hasTag("flesh") ||*/ b.hasTag("scenary");
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
