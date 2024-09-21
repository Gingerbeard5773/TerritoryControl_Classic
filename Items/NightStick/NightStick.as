#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore fall");
	this.set_u32("next attack", 0);

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2);
	}
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
	const bool pressing_action1 = isBot ? holder.isKeyPressed(key_action1) : point.isKeyJustPressed(key_action1);

	if (!pressing_action1) return;

	u8 team = holder.getTeamNum();
	
	HitInfo@[] hitInfos;
	if (getMap().getHitInfosFromArc(this.getPosition(), -(holder.getAimPos() - this.getPosition()).Angle(), 45, 16, this, @hitInfos))
	{
		for (uint i = 0; i < hitInfos.length; i++)
		{
			CBlob@ blob = hitInfos[i].blob;
			if (blob !is null && blob.hasTag("flesh"))
			{
				if (isServer())
				{
					u8 knock;
					if (blob.getConfig() == "slave") knock = 30 + (1.0f - (blob.getHealth() / blob.getInitialHealth())) * (30 + XORRandom(50)) * 2.5f;
					else knock = 15 + (1.0f - (blob.getHealth() / blob.getInitialHealth())) * (30 + XORRandom(50));
				
					blob.set_u8("knocked", knock);
					blob.Sync("knocked", true);
				}
				
				if (isClient())
				{
					this.getSprite().PlaySound("nightstick_hit" + (1 + XORRandom(3)) + ".ogg", 0.9f, 0.8f);
				}
				
				if (isServer())
				{
					holder.server_Hit(blob, blob.getPosition(), Vec2f(), 0.125f, Hitters::stomp, true);
					holder.server_Hit(this, this.getPosition(), Vec2f(), 0.125f, Hitters::stomp, true);
				}
			}
		}
	}
	
	this.set_u32("next attack", getGameTime() + 30);
}
