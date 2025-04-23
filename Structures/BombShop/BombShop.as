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

	this.setInventoryName(name(Translate::Bombshop));

	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, name(Translate::Bombshop));
	shop.menu_size = Vec2f(4, 6);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 15;
	
	{
		SaleItem s(shop.items, name(Translate::TankShell)+" (4)", "$icon_tankshell$", "mat_tankshell", desc(Translate::TankShell), ItemType::material, 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		SaleItem s(shop.items, name(Translate::HowitzerShell)+" (2)", "$icon_howitzershell$", "mat_howitzershell", desc(Translate::HowitzerShell), ItemType::material, 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
	}
	{
		SaleItem s(shop.items, name(Translate::Rocket), "$icon_rocket$", "rocket", desc(Translate::Rocket));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "blob", "mat_coal", Translate::Coal, 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		SaleItem s(shop.items, name(Translate::BigBomb), "$icon_bigbomb$", "mat_bigbomb", desc(Translate::BigBomb), ItemType::material, 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		s.button_dimensions = Vec2f(1, 2);
	}
	{
		SaleItem s(shop.items, "Mine", "$mine$", "mine", Descriptions::mine);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
	}
	{
		SaleItem s(shop.items, name(Translate::Fragmine), "$icon_fragmine$", "fragmine", desc(Translate::Fragmine));
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
	{
		SaleItem s(shop.items, "Bomb", "$bomb$", "mat_bombs", Descriptions::bomb, ItemType::material, 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		SaleItem s(shop.items, "Bomb Arrow", "$mat_bombarrows$", "mat_bombarrows", Descriptions::bombarrows, ItemType::material, 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		SaleItem s(shop.items, name(Translate::SmallBomb)+" (4)", "$icon_smallbomb$", "mat_smallbomb", desc(Translate::SmallBomb), ItemType::material, 4);
		AddRequirement(s.requirements, "coin", "", "Coins", 130);
	}
	{
		SaleItem s(shop.items, name(Translate::IncendiaryBomb), "$icon_incendiarybomb$", "mat_incendiarybomb", desc(Translate::IncendiaryBomb), ItemType::material, 1);
		AddRequirement(s.requirements, "blob", "mat_oil", Translate::Oil, 25);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
	}
	{
		SaleItem s(shop.items, "Keg", "$keg$", "keg", Descriptions::keg);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
	}
	/*{
		SaleItem s(shop.items, name(Translate::BunkerBuster), "$icon_bunkerbuster$", "mat_bunkerbuster", desc(Translate::BunkerBuster), ItemType::material, 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_sulphur", Translate::Sulphur, 25);
	}*/
	{
		SaleItem s(shop.items, name(Translate::StunBomb)+" (2)", "$icon_stunbomb$", "mat_stunbomb", desc(Translate::StunBomb), ItemType::material, 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_methane", Translate::Methane, 25);
	}
	{
		SaleItem s(shop.items, name(Translate::Nuke), "$icon_nuke$", "nuke", desc(Translate::Nuke));
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 40);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 20);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100); // Cart!
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);
	}
	{
		SaleItem s(shop.items, name(Translate::Claymore), "$icon_claymore$", "claymore", desc(Translate::Claymore));
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
	}
	{
		SaleItem s(shop.items, name(Translate::SmallRocket), "$icon_smallrocket$", "mat_smallrocket", desc(Translate::SmallRocket), ItemType::material, 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
	}
	{
		SaleItem s(shop.items, name(Translate::ClaymoreRemote), "$icon_claymoreremote$", "claymoreremote", desc(Translate::ClaymoreRemote));
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
	}
	/*{
		SaleItem s(shop.items, name(Translate::SmokeGrenade), "$icon_smokegrenade$", "mat_smokegrenade", desc(Translate::SmokeGrenade));
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_sulphur", Translate::Sulphur, 25);
	}*/
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("ConstructShort.ogg");
	
	CPlayer@ player = caller.getPlayer();
	if (player !is null && blob !is null && blob.getName() == "nuke")
	{
		blob.set_string("Owner", player.getUsername());
		blob.SetDamageOwnerPlayer(player);
	}
}
