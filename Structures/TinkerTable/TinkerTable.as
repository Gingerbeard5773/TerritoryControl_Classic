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
	this.Tag("has window");
	
	this.getCurrentScript().tickFrequency = 150;

	this.setInventoryName(name(Translate::Mechanist));
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, name(Translate::Mechanist));
	shop.menu_size = Vec2f(5, 4);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 15;

	{
		SaleItem s(shop.items, "Drill", "$drill$", "drill", Descriptions::drill);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		SaleItem s(shop.items, name(Translate::Gramophone), "$gramophone$", "gramophone", desc(Translate::Gramophone));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 1);
	}
	{
		SaleItem s(shop.items, "Saw", "$saw$", "saw", Descriptions::saw);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
	}
	{
		SaleItem s(shop.items, name(Translate::PowerDrill), "$powerdrill$", "powerdrill", desc(Translate::PowerDrill));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 2);
		AddRequirement(s.requirements, "blob", "mat_copperwire", name(Translate::CopperWire), 2);
	}
	{
		SaleItem s(shop.items, name(Translate::Contrabass), "$contrabass$", "contrabass", desc(Translate::Contrabass));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 60);
		AddRequirement(s.requirements, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
	}
	{
		SaleItem s(shop.items, name(Translate::CopperWire)+" (2)", "$mat_copperwire$", "mat_copperwire", desc(Translate::CopperWire), ItemType::material, 2);
		AddRequirement(s.requirements, "blob", "mat_copperingot", name(Translate::CopperIngot), 1);
	}	
	{
		SaleItem s(shop.items, name(Translate::Klaxon), "$icon_klaxon$", "klaxon", desc(Translate::Klaxon));
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 666);
	}	
	{
		SaleItem s(shop.items, name(Translate::Automat), "$icon_automat$", "automat", desc(Translate::Automat));
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 4);
		AddRequirement(s.requirements, "blob", "fishy", "Fishy", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);
	}
	{
		SaleItem s(shop.items, name(Translate::GasExtractor), "$icon_gasextractor$", "gasextractor", desc(Translate::GasExtractor));
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 2);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.button_dimensions = Vec2f(2, 1);
	}
	{
		SaleItem s(shop.items, name(Translate::MustardGas), "$icon_mustard$", "mat_mustard", desc(Translate::MustardGas), ItemType::material, 50);
		AddRequirement(s.requirements, "blob", "mat_sulphur", Translate::Sulphur, 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		SaleItem s(shop.items, name(Translate::Backpack), "$icon_backpack$", "backpack", desc(Translate::Backpack));
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	{
		SaleItem s(shop.items, name(Translate::Parachutepack), "$icon_parachutepack$", "parachutepack", desc(Translate::Parachutepack));
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	{
		SaleItem s(shop.items, name(Translate::Jetpack), "$icon_jetpack$", "jetpack", desc(Translate::Jetpack));
		AddRequirement(s.requirements, "blob", "mat_smallrocket", name(Translate::SmallRocket), 2);
		AddRequirement(s.requirements, "blob", "mat_oil", Translate::Oil, 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	{
		SaleItem s(shop.items, name(Translate::ScubaGear), "$icon_scubagear$", "scubagear", desc(Translate::ScubaGear));
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 1);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("ConstructShort.ogg");
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	CBlob@[] blobs;
	getMap().getBlobsInBox(this.getPosition() + Vec2f(96, 64), this.getPosition() + Vec2f(-96, 0), @blobs);
	for (u16 i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (!blob.hasTag("vehicle") || blob.getHealth() >= blob.getInitialHealth()) continue;

		blob.server_Heal(1);
	}
}
