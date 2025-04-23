// A script by TFlippy

#include "Requirements.as";
#include "StoreCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

const string[] resources = 
{
	"mat_pistolammo",
	"mat_rifleammo",
	"mat_shotgunammo",
	"mat_gatlingammo"
};

const u8[] resourceYields = 
{
	3,
	2,
	2,
	5
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("has window");

	this.getCurrentScript().tickFrequency = 300;
	this.inventoryButtonPos = Vec2f(-8, 0);

	this.setInventoryName(name(Translate::Gunsmith));
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, name(Translate::Gunsmith)+" ");
	shop.menu_size = Vec2f(4, 4);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 15;

	{
		SaleItem s(shop.items, name(Translate::LowCalAmmo)+" (20)", "$icon_pistolammo$", "mat_pistolammo", desc(Translate::LowCalAmmo), ItemType::material, 20);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		SaleItem s(shop.items, name(Translate::HighCalAmmo)+" (5)", "$icon_rifleammo$", "mat_rifleammo", desc(Translate::HighCalAmmo), ItemType::material, 5);
		AddRequirement(s.requirements, "coin", "", "Coins", 45);
	}
	{
		SaleItem s(shop.items, name(Translate::ShotgunAmmo)+" (4)", "$icon_shotgunammo$", "mat_shotgunammo", desc(Translate::ShotgunAmmo), ItemType::material, 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
	}
	{
		SaleItem s(shop.items, name(Translate::MachinegunAmmo)+" (30)", "$icon_gatlingammo$", "mat_gatlingammo", desc(Translate::MachinegunAmmo), ItemType::material, 30);
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
	}
	{
		SaleItem s(shop.items, name(Translate::Revolver), "$icon_revolver$", "revolver", desc(Translate::Revolver));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		s.button_dimensions = Vec2f(2, 1);
	}
	{
		SaleItem s(shop.items, name(Translate::Rifle), "$icon_rifle$", "rifle", desc(Translate::Rifle));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 60);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		s.button_dimensions = Vec2f(2, 1);
	}
	{
		SaleItem s(shop.items, name(Translate::SMG), "$icon_smg$", "smg", desc(Translate::SMG));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.button_dimensions = Vec2f(2, 1);
	}
	{
		SaleItem s(shop.items, name(Translate::Bazooka), "$icon_bazooka$", "bazooka", desc(Translate::Bazooka));
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", name(Translate::CopperIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.button_dimensions = Vec2f(2, 1);
	}
	{
		SaleItem s(shop.items, name(Translate::Scorcher), "$icon_flamethrower$", "flamethrower", desc(Translate::Scorcher));
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", name(Translate::CopperIngot), 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.button_dimensions = Vec2f(2, 1);
	}
	{
		SaleItem s(shop.items, name(Translate::Shotgun), "$icon_shotgun$", "shotgun", desc(Translate::Shotgun));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 70);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 3);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.button_dimensions = Vec2f(2, 1);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("ConstructShort.ogg");
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		const u8 index = XORRandom(resources.length);
		if (!this.getInventory().isFull())
		{
			Material::createFor(this, resources[index], XORRandom(resourceYields[index]));
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this) && forBlob.getCarriedBlob() is null;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	Shop@ shop;
	if (!this.get("shop", @shop)) return;

	shop.button_offset = isInventoryAccessible(this, caller) ? Vec2f(8, 0) : Vec2f_zero;
}
