// A script by TFlippy

#include "Requirements.as";
#include "StoreCommon.as";
#include "Descriptions.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("builder always hit");
	
	this.getCurrentScript().tickFrequency = 300;
	
	this.inventoryButtonPos = Vec2f(-8, 0);
	this.addCommandID("sv_store");

	this.setInventoryName(name(Translate::Armory));
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, name(Translate::Armory)+" ");
	shop.menu_size = Vec2f(3, 2);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 15;

	{
		SaleItem s(shop.items, name(Translate::RoyalArmor), "$icon_royalarmor$", "royalarmor", desc(Translate::RoyalArmor));
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 8);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		SaleItem s(shop.items, name(Translate::Nightstick), "$nightstick$", "nightstick", desc(Translate::Nightstick));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
	}
	{
		SaleItem s(shop.items, name(Translate::Shackles), "$icon_shackles$", "shackles", desc(Translate::Shackles));
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		SaleItem s(shop.items, "Water Bombs", "$waterbomb$", "mat_waterbombs", Descriptions::waterbomb, ItemType::material, 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}	
	{
		SaleItem s(shop.items, "Water Arrows", "$mat_waterarrows$", "mat_waterarrows", Descriptions::waterarrows, ItemType::material, 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 20);
	}
	{
		SaleItem s(shop.items, "Fire Arrows", "$mat_firearrows$", "mat_firearrows", Descriptions::firearrows, ItemType::material, 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("ConstructShort.ogg");
}

void onTick(CBlob@ this)
{
	if (this.getInventory().isFull()) return;

	CBlob@[] blobs;
	getMap().getBlobsInBox(this.getPosition() + Vec2f(128, 96), this.getPosition() + Vec2f(-128, -96), @blobs);

	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (canPickup(blob) && !blob.isAttached())
		{
			if (isClient() && this.getInventory().canPutItem(blob)) blob.getSprite().PlaySound("/PutInInventory.ogg");
			if (isServer()) this.server_PutInInventory(blob);
		}
	}
}

bool canPickup(CBlob@ blob)
{
	return blob.hasTag("gun") || blob.hasTag("ammo");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CBlob@ carried = forBlob.getCarriedBlob();
	return forBlob.isOverlapping(this) && (carried is null ? true : carried.hasTag("gun") || carried.hasTag("ammo"));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	Shop@ shop;
	if (!this.get("shop", @shop)) return;

	if (isInventoryAccessible(this, caller))
	{
		shop.button_offset = Vec2f(8, 0);

		CInventory@ inv = caller.getInventory();
		if (inv is null) return;

		for (int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ item = inv.getItem(i);
			if (!canPickup(item)) continue;

			caller.CreateGenericButton(28, Vec2f(0, -10), this, this.getCommandID("sv_store"), "Store");
			break;
		}
	}
	else
	{
		shop.button_offset = Vec2f_zero;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sv_store") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		CBlob@ caller = player.getBlob();
		if (caller is null) return;

		CBlob@ carried = caller.getCarriedBlob();
		if (carried !is null && carried.hasTag("temp blob"))
		{
			carried.server_Die();
		}

		CInventory@ inv = caller.getInventory();
		if (inv is null) return;

		for (int i = inv.getItemsCount() - 1; i >= 0; i--)
		{
			CBlob@ item = inv.getItem(i);
			if (!canPickup(item)) continue;

			caller.server_PutOutInventory(item);
			this.server_PutInInventory(item);
		}
	}
}
