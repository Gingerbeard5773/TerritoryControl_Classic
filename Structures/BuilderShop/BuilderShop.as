// A script by TFlippy

#include "Requirements.as"
#include "StoreCommon.as"
#include "Descriptions.as"
#include "GenericButtonCommon.as"
#include "TeamIconToken.as"
#include "TC_Translation.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("has window");
	this.Tag("builder always hit");
	
	const u8 team_num = this.getTeamNum();
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, "Builder's Workshop");
	shop.menu_size = Vec2f(3, 3);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 15;

	{
		SaleItem s(shop.items, "Lantern", "$lantern$", "lantern", Descriptions::lantern);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
	}
	{
		SaleItem s(shop.items, "Bucket", "$bucket$", "bucket", Descriptions::bucket);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
	}
	{
		SaleItem s(shop.items, "Sponge", "$sponge$", "sponge", Descriptions::sponge);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		SaleItem s(shop.items, "Trampoline", getTeamIcon("trampoline", "Trampoline.png", team_num, Vec2f(32, 16), 3), "trampoline", Descriptions::trampoline);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
	}
	{
		SaleItem s(shop.items, "Crate", "$crate$", "crate", Descriptions::crate);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
	}
	{
		SaleItem s(shop.items, name(Translate::Chair), "$chair$", "chair", desc(Translate::Chair));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
	}
	{
		SaleItem s(shop.items, name(Translate::Table), "$table$", "table", desc(Translate::Table));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("ConstructShort.ogg");
}
