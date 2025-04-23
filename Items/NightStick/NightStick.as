#include "Hitters.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Nightstick));
	this.Tag("ignore fall");
	this.set_u32("next attack", 0);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2);
	}
	
	this.addCommandID("client_nightstick_hit");
}

void onTick(CBlob@ this)
{	
	if (!this.isAttached()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;

	if (this.get_u32("next attack") > getGameTime())
	{
		if (this.get_u32("next attack") - getGameTime() > 20)
		{
			this.getSprite().ResetTransform();
			this.getSprite().RotateBy((getGameTime() - this.get_u32("next attack")) * -40, Vec2f());
		}
		else this.getSprite().ResetTransform();
		
		return;
	}
	
	if (holder.get_u8("knocked") > 0) return;
	
	const bool isBot = holder.getPlayer() is null;
	const bool pressing_action1 = isBot ? holder.isKeyPressed(key_action1) : point.isKeyPressed(key_action1);

	if (!pressing_action1) return;

	if (isServer())
	{
		HitInfo@[] hitInfos;
		if (getMap().getHitInfosFromArc(this.getPosition(), -(holder.getAimPos() - this.getPosition()).Angle(), 45, 16, this, @hitInfos))
		{
			for (uint i = 0; i < hitInfos.length; i++)
			{
				CBlob@ blob = hitInfos[i].blob;
				if (blob is null || !blob.hasTag("flesh")) continue;

				const u8 base_knock = 20 + (1.0f - (blob.getHealth() / blob.getInitialHealth())) * (30 + XORRandom(50));
				const u8 knock = blob.getName() == "slave" ? 10 + base_knock * 2.5f : base_knock;
			
				blob.set_u8("knocked", knock);
				blob.Sync("knocked", true);

				holder.server_Hit(blob, blob.getPosition(), Vec2f(), 0.125f, Hitters::stomp, true);
				holder.server_Hit(this, this.getPosition(), Vec2f(), 0.125f, Hitters::stomp, true);
				
				this.SendCommand(this.getCommandID("client_nightstick_hit"));
			}
		}
	}
	
	this.set_u32("next attack", getGameTime() + 30);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client_nightstick_hit") && isClient())
	{
		this.getSprite().PlaySound("nightstick_hit" + (1 + XORRandom(3)) + ".ogg", 0.9f, 0.8f);
	}
}
