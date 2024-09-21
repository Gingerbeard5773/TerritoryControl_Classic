//Auto Ammo Pickup

#define SERVER_ONLY

#include "GunCommon.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
}

void Take(CBlob@ this, CBlob@ blob)
{
	if (this.isAttached() || !blob.hasTag("material") || blob.hasTag("no pickup")) return;

	if (blob.getShape().vellen > 1.0f) return;

	if (getGameTime() <= blob.get_u32("autopick time")) return;

	CBlob@[] inventory_guns;
	CBlob@ carried = this.getCarriedBlob();
	if (carried !is null && carried.hasTag("gun"))
	{
		inventory_guns.push_back(carried);
	}
	
	CInventory@ inv = this.getInventory();
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		if (!item.hasTag("gun")) continue;

		inventory_guns.push_back(item);
	}

	for (int i = 0; i < inventory_guns.size(); i++)
	{
		CBlob@ inventory_gun = inventory_guns[i];

		GunInfo@ gun;
		if (!inventory_gun.get("gunInfo", @gun)) return;

		if (gun.ammo_name == blob.getName())
		{
			this.server_PutInInventory(blob);
			break;
		}
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	Take(this, blob);
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;
	if (!this.getOverlapping(@overlapping)) return;

	for (uint i = 0; i < overlapping.length; i++)
	{
		CBlob@ blob = overlapping[i];
		Take(this, blob);
	}
}
