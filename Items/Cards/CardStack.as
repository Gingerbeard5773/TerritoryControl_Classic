#include "TC_Translation.as";

const string[] types =
{
	"death_cards",
	"holy_cards",
	"nature_cards",
	"water_cards",
	"fire_cards",
	"cog_cards",
	"steam_cards",
	"mine_cards"
};
 
void onInit(CBlob@ this)
{
	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PICKUP");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_action1 | key_action2 | key_action3);
	}
	this.set_u8("type", 0);

	this.maxQuantity = 50;

	this.setInventoryName(getTranslatedInventoryName(this));
}

string getTranslatedInventoryName(CBlob@ this)
{
	const string blob_name = this.getName();
	if (blob_name == "death_cards")  return Translate::DeathCards;
	if (blob_name == "holy_cards")   return Translate::HolyCards;
	if (blob_name == "nature_cards") return Translate::NatureCards;
	if (blob_name == "water_cards")  return Translate::WaterCards;
	if (blob_name == "fire_cards")   return Translate::FireCards;
	if (blob_name == "cog_cards")    return Translate::CogCards;
	if (blob_name == "steam_cards")  return Translate::SteamCards;
	if (blob_name == "mine_cards")   return Translate::MineCards;
	if (blob_name == "chaos_cards")  return Translate::ChaosCards;

	return this.getInventoryName();
}

void onTick(CBlob@ this)
{
	if (this.isAttached())
	{
		this.getCurrentScript().runFlags &= ~(Script::tick_not_sleeping);
		AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
		CBlob@ holder = point.getOccupied();
		if (holder is null) return;

		this.getShape().SetRotationsAllowed(false);
		
		const bool isBot = holder.getPlayer() is null;
		const bool pressing_action1 = isBot ? holder.isKeyPressed(key_action1) : point.isKeyJustPressed(key_action1);

		if (pressing_action1 && holder.get_u8("knocked") <= 0 && isServer())
		{
			CBlob@ blob = server_CreateBlob("card", holder.getTeamNum(), this.getPosition());
			if (blob !is null)
			{
				Vec2f shootVel = holder.getAimPos() - this.getPosition();
				shootVel.Normalize();
				blob.setVelocity(shootVel * 12);
				blob.SetDamageOwnerPlayer(holder.getPlayer());
				blob.set_u8("type", GetCardType(this));
			}

			this.server_SetQuantity(this.getQuantity() - 1);
			if (this.getQuantity() <= 0) this.server_Die();
		}
	}
	else
	{
		this.getShape().SetRotationsAllowed(true);
	}
}
 
u8 GetCardType(CBlob@ this)
{
	string name = this.getName();
	for (u8 i = 0; i < types.length; i++)if (name == types[i]) return i;
	return XORRandom(types.length);
}
 
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	this.getCurrentScript().runFlags &= ~Script::tick_not_sleeping;
}
