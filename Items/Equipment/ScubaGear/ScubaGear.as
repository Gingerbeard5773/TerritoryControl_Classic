#include "EquipmentCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::ScubaGear));
	this.set_string("equipment_slot", "head");

	addOnEquip(this, @OnEquip);
	addOnUnequip(this, @OnUnequip);
	addOnTickEquipped(this, @onTickEquipped);
}

void OnEquip(CBlob@ this, CBlob@ equipper)
{
	LoadNewHead(equipper, 146);

	equipper.Tag("scubagear");
	this.set_u8("breath timer", 1);
	this.set_bool("inhale", false);
}

void OnUnequip(CBlob@ this, CBlob@ equipper)
{
	LoadOldHead(equipper);

	equipper.Untag("scubagear");
}

void onTickEquipped(CBlob@ this, CBlob@ equipper)
{
	if (isClient() && (getGameTime() + equipper.getNetworkID()) % 30 == 0)
	{
		if (this.get_u8("breath timer") == 2)
		{
			const bool inhale = this.get_bool("inhale");
			equipper.getSprite().PlaySound("Sounds/gasp.ogg", 0.75f, inhale ? 0.8f : 0.75f);
			this.set_bool("inhale", !inhale);
		}
		this.set_u8("breath timer", (this.get_u8("breath timer") % 2) + 1);
	}
}
