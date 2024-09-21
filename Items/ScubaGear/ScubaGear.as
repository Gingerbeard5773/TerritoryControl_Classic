#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.set_string("equipment_slot", "head");

	addOnEquip(this, @OnEquip);
	addOnUnequip(this, @OnUnequip);
}

void OnEquip(CBlob@ this, CBlob@ equipper)
{
	LoadNewHead(equipper, 146);

	equipper.Tag("scubagear");
	equipper.AddScript("ScubaGearEffect.as");
	
	if (equipper.exists("air_count"))
	{
		equipper.set_u8("air_count", 180);
		equipper.RemoveScript("RunnerDrowning.as");
	}
}

void OnUnequip(CBlob@ this, CBlob@ equipper)
{
	LoadOldHead(equipper);

	equipper.Untag("scubagear");
	equipper.RemoveScript("ScubaGearEffect.as");
	
	if (equipper.exists("air_count"))
	{
		equipper.AddScript("RunnerDrowning.as");
	}
}

//temporary until equipment is officially added in
//equipment.as should be in player scripts not here
void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @attachedPoint)
{
	if (attached.hasTag("player") && !attached.hasTag("can use equipment"))
	{
		attached.Tag("can use equipment");
		attached.AddScript("Equipment.as");
	}
}
