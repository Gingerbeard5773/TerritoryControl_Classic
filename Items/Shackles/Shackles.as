#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Shackles));
	this.Tag("ignore fall");
	this.set_u32("next attack", getGameTime());

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1);
	}
}

void onTick(CBlob@ this)
{	
	if (!this.isAttached()) return;

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	if (holder is null) return;

	if (this.get_u32("next attack") > getGameTime()) return;
	
	if (holder.get_u8("knocked") > 0) return;

	const bool isBot = holder.getPlayer() is null;
	const bool pressing_action1 = isBot ? holder.isKeyPressed(key_action1) : point.isKeyJustPressed(key_action1);

	if (!pressing_action1) return;

	const u8 team = holder.getTeamNum();
	
	HitInfo@[] hitInfos;
	getMap().getHitInfosFromArc(this.getPosition(), -(holder.getAimPos() - this.getPosition()).Angle(), 45, 16, this, @hitInfos);
	
	for (uint i = 0; i < hitInfos.length; i++)
	{
		CBlob@ blob = hitInfos[i].blob;
		if (blob !is null && blob.hasTag("player") && blob.getTeamNum() != team && blob.getPlayer() !is null)
		{
			Random rand(this.getNetworkID() + this.get_u32("next attack"));
			const f32 chance = 1.0f - (blob.getHealth() / blob.getInitialHealth());
			if ((chance > 0.50f && rand.NextRanged(100) < chance * 80) || (blob.get_u8("knocked") > 30 && chance > 0.2f))
			{
				if (isClient())
				{
					this.getSprite().PlaySound("shackles_success.ogg", 1.25f, 1.00f);
				}
				
				if (isServer())
				{
					CBlob@ slave = server_CreateBlob("slave", blob.getTeamNum(), blob.getPosition());
					if (slave !is null)
					{
						if (blob.getPlayer() !is null) slave.server_SetPlayer(blob.getPlayer());
						blob.server_Die();
						this.server_Die();
					}
				}
				
				return;
			}
			else
			{
				if (isServer())
				{
					this.set_u32("next attack", getGameTime() + 90);
					this.Sync("next attack", true);
				}
			
				if (isClient())
				{
					this.getSprite().PlaySound("shackles_fail.ogg", 0.80f, 1.00f);
				}
				
				return;
			}
		}
	}
	
	if (holder.isMyPlayer())
	{
		Sound::Play("/NoAmmo", this.getPosition());
	}
}
