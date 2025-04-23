// A script by TFlippy

#include "Requirements.as";
#include "StoreCommon.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(500); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 300;
	
	this.getShape().SetOffset(Vec2f(0, 4));
	
	u16[] spawnedIDs;
	this.set("blobIDs", spawnedIDs);

	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, "Badger Den");
	shop.menu_size = Vec2f(2, 1);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 25;

	{
		SaleItem s(shop.items, "Sell a Steak (1)", "$steak$", "coin", "Groo. <3", ItemType::coin, 100);
		AddRequirement(s.requirements, "blob", "steak", "Steak", 1);
	}
	{
		SaleItem s(shop.items, "Buy a Friend (1)", "$heart$", "scyther", "Moo. >:(");
		AddRequirement(s.requirements, "coin", "", "Coins", 6666);
		AddRequirement(s.requirements, "blob", "steak", "Steak", 3);
		AddRequirement(s.requirements, "blob", "heart", "Heart", 2);
		AddRequirement(s.requirements, "blob", "cake", "Cinnamon bun",1);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("badger_growl" + (XORRandom(6) + 1) + ".ogg");
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	if (XORRandom(100) >= 50) return;

	u16[] spawnedIDs;
	this.get("blobIDs", spawnedIDs);

	for (int i = 0; i < spawnedIDs.length; i++)
	{
		CBlob@ blob = getBlobByNetworkID(spawnedIDs[i]);
		if (blob is null || blob.hasTag("dead"))
		{
			this.removeAt("blobIDs", i);
		}
	}
	
	this.get("blobIDs", spawnedIDs);
	if (spawnedIDs.length < 3)
	{
		CBlob@ blob = server_CreateBlob("badger", -1, this.getPosition());
		if (blob !is null)
		{
			this.push("blobIDs", blob.getNetworkID());
		}
	}
}
