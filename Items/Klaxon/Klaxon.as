#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Klaxon));
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

	if (holder.get_u8("knocked") <= 0)
	{
		const bool isBot = holder.getPlayer() is null;
		const bool pressing_action1 = isBot ? holder.isKeyPressed(key_action1) : point.isKeyJustPressed(key_action1);
		if (pressing_action1)
		{
			if (this.get_u32("next attack") > getGameTime()) return;
		
			if (isClient())
			{
				this.getSprite().PlaySound("klaxon" + XORRandom(4) + ".ogg", 0.8f, 1.0f);
				this.getSprite().SetAnimation("default");
				this.getSprite().SetAnimation("honk");
			}
			
			this.set_u32("next attack", getGameTime() + 10);
		}
	}
}
