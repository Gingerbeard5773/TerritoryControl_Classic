#include "TC_Translation.as";

const u32 shackle_delay = 90;

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
	
	this.addCommandID("client_slave_sound");
	
	AddIconToken("$opaque_heatbar$", "Entities/Industry/Drill/HeatBar.png", Vec2f(24, 6), 0);
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
			if (isServer())
			{
				CBitStream stream;
				Random rand(this.getNetworkID() + this.get_u32("next attack"));
				const f32 chance = 1.0f - (blob.getHealth() / blob.getInitialHealth());
				if ((chance > 0.50f && rand.NextRanged(100) < chance * 80) || (blob.get_u8("knocked") > 30 && chance > 0.2f))
				{
					CBlob@ slave = server_CreateBlob("slave", blob.getTeamNum(), blob.getPosition());
					if (slave !is null)
					{
						if (blob.getPlayer() !is null) slave.server_SetPlayer(blob.getPlayer());
						blob.server_Die();
						this.server_Die();
						
						stream.write_bool(true);
						this.SendCommand(this.getCommandID("client_slave_sound"), stream);
					}
				}
				else
				{
					this.set_u32("next attack", getGameTime() + shackle_delay);
					this.Sync("next attack", true);
					
					stream.write_bool(false);
					this.SendCommand(this.getCommandID("client_slave_sound"), stream);
				}
			}
			return;
		}
	}
	
	if (holder.isMyPlayer())
	{
		Sound::Play("/NoAmmo", this.getPosition());
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("client_slave_sound") && isClient())
	{
		bool success;
		if (!params.saferead_bool(success)) return;
		
		if (success)
		{
			this.getSprite().PlaySound("shackles_success.ogg", 1.25f, 1.00f);
		}
		else
		{
			this.getSprite().PlaySound("shackles_fail.ogg", 0.80f, 1.00f);
		}
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	AttachmentPoint@ point = blob.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	if (holder is null || !holder.isMyPlayer()) return;
	
	const u32 next_attack = blob.get_u32("next attack");
	if (next_attack <= getGameTime()) return;
	
	const u32 time = getGameTime() - (next_attack - shackle_delay);
	const f32 percentage = f32(time) / f32(shackle_delay);

	Vec2f pos = holder.getInterpolatedScreenPos() + Vec2f(-22, 16);
	Vec2f dimension = Vec2f(42, 4);
	Vec2f bar = Vec2f(pos.x + (dimension.x * percentage), pos.y + dimension.y);

	GUI::DrawIconByName("$opaque_heatbar$", pos);
	GUI::DrawRectangle(pos + Vec2f(4, 4), bar + Vec2f(4, 4), SColor(255, 28, 2, 130));
	GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 4), SColor(255, 30, 51, 158));
	GUI::DrawRectangle(pos + Vec2f(6, 6), bar + Vec2f(2, 2), SColor(255, 55, 55, 198));
}
