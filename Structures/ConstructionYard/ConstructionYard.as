// Vehicle Workshop

#include "Requirements.as";
#include "StoreCommon.as";
#include "Descriptions.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.setInventoryName(name(Translate::Yard));

	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, name(Translate::Yard));
	shop.menu_size = Vec2f(12, 6);
	shop.button_offset = Vec2f(0, 8);
	shop.button_icon = 15;
	
	{
		SaleItem s(shop.items, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + Descriptions::catapult, ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.crate_frame_index = 4;
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + Descriptions::ballista, ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.crate_frame_index = 5;
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, name(Translate::SteamTank), "$icon_steamtank$", "steamtank", "$icon_steamtank$\n\n\n" + desc(Translate::SteamTank), ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 10);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.crate_frame_index = 7;
		s.button_dimensions = Vec2f(2, 2);
	}
	/*{
		SaleItem s(shop.items, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], ItemType::material, 12);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.button_dimensions = Vec2f(2, 2);
	}*/
	{
		SaleItem s(shop.items, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + Descriptions::dinghy);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + Descriptions::longboat, ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
		s.crate_frame_index = 1;
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + Descriptions::warboat, ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_frame_index = 2;
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, name(Translate::Machinegun), "$icon_gatlinggun$", "gatlinggun", desc(Translate::Machinegun), ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 4);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.crate_frame_index = 11;
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, name(Translate::Mortar), "$icon_mortar$", "mortar", desc(Translate::Mortar), ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 6);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.crate_frame_index = 3;
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, "Bomber", "$icon_bomber$", "bomber", "$icon_bomber$\n\n\n\n\n\n\n\n" + desc(Translate::Bomber), ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.crate_frame_index = 13;
		s.button_dimensions = Vec2f(4, 4);
	}
	{
		SaleItem s(shop.items, name(Translate::ArmoredBomber), "$icon_armoredbomber$", "armoredbomber", "$icon_armoredbomber$\n\n\n\n\n\n\n\n" + desc(Translate::ArmoredBomber), ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 5);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_frame_index = 13;
		s.button_dimensions = Vec2f(4, 4);
	}
	{
		SaleItem s(shop.items, name(Translate::Howitzer), "$icon_howitzer$", "howitzer", desc(Translate::Howitzer), ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 5);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_frame_index = 12;
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, name(Translate::RocketLauncher), "$icon_rocketlauncher$", "rocketlauncher", desc(Translate::RocketLauncher), ItemType::crate);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.crate_frame_index = 12;
		s.button_dimensions = Vec2f(2, 2);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("ConstructShort.ogg");
}

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 64, 56, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(1);
		planks.SetOffset(Vec2f(0.0f, 0.0f));
		planks.SetRelativeZ(-100);
	}
}
