// A script by TFlippy

#include "Requirements.as";
#include "StoreCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("builder always hit");

	this.setInventoryName(name(Translate::Forge));

	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, name(Translate::Forge));
	shop.menu_size = Vec2f(4, 2);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 15;
	
	{
		SaleItem s(shop.items, name(Translate::CopperIngot)+" (1)", "$icon_copperingot$", "mat_copperingot", desc(Translate::CopperIngot), ItemType::material, 1);
		AddRequirement(s.requirements, "blob", "mat_copper", Translate::CopperOre, 10);
	}
	{
		SaleItem s(shop.items, name(Translate::IronIngot)+" (1)", "$icon_ironingot$", "mat_ironingot", desc(Translate::IronIngot), ItemType::material, 1);
		AddRequirement(s.requirements, "blob", "mat_iron", Translate::IronOre, 10);
	}
	{
		SaleItem s(shop.items, name(Translate::SteelIngot)+" (1)", "$icon_steelingot$", "mat_steelingot", desc(Translate::SteelIngot), ItemType::material, 1);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 4);
		AddRequirement(s.requirements, "blob", "mat_coal", Translate::Coal, 1);
	}
	{
		SaleItem s(shop.items, name(Translate::GoldIngot)+" (1)", "$icon_goldingot$", "mat_goldingot", desc(Translate::GoldIngot), ItemType::material, 1);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 25);
	}
	
	// Large batch
	{
		SaleItem s(shop.items, name(Translate::CopperIngot)+" (4)", "$icon_copperingot$", "mat_copperingot", desc(Translate::CopperIngot), ItemType::material, 4);
		AddRequirement(s.requirements, "blob", "mat_copper", Translate::CopperOre, 40);
	}
	{
		SaleItem s(shop.items, name(Translate::IronIngot)+" (4)", "$icon_ironingot$", "mat_ironingot", desc(Translate::IronIngot), ItemType::material, 4);
		AddRequirement(s.requirements, "blob", "mat_iron", Translate::IronOre, 40);
	}
	{
		SaleItem s(shop.items, name(Translate::SteelIngot)+" (4)", "$icon_steelingot$", "mat_steelingot", desc(Translate::SteelIngot), ItemType::material, 4);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 16);
		AddRequirement(s.requirements, "blob", "mat_coal", Translate::Coal, 4);
	}
	{
		SaleItem s(shop.items, name(Translate::GoldIngot)+" (4)", "$icon_goldingot$", "mat_goldingot", desc(Translate::GoldIngot), ItemType::material, 4);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 100);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("ConstructShort.ogg");
}
