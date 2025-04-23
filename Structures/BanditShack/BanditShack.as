// A script by TFlippy

#include "Requirements.as";
#include "StoreCommon.as";
#include "StandardRespawnCommand.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.Tag("respawn");

	this.Tag("builder always hit");
	
	this.set_string("required class", "bandit");
	this.set_string("required tag", "neutral");
	this.set_Vec2f("class offset", Vec2f(-4, 0));

	this.setInventoryName(Translate::RatDen);

	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, Translate::RatDen);
	shop.menu_size = Vec2f(4, 2);
	shop.button_offset = Vec2f(4, 0);
	shop.button_icon = 25;
	
	{
		SaleItem s(shop.items, name(Translate::RatBurger), "$ratburger$", "ratburger", desc(Translate::RatBurger));
		AddRequirement(s.requirements, "coin", "", "Coins", 31);
	}
	{
		SaleItem s(shop.items, name(Translate::RatFood), "$ratfood$", "ratfood", desc(Translate::RatFood));
		AddRequirement(s.requirements, "coin", "", "Coins", 17);
	}
	/*{
		SaleItem s(shop.items, "Some Badger", "$badger$", "badger", "I found ths guy under my bed.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}*/
	{
		SaleItem s(shop.items, sell(Translate::ScrubChow, "1"), "$COIN$", "coin", Translate::SellChow.replace("{COINS}", "29"), ItemType::coin, 29);
		AddRequirement(s.requirements, "blob", "foodcan", name(Translate::ScrubChow), 1);
	}
	{
		SaleItem s(shop.items, sell(Translate::ScrubChowXL, "1"), "$COIN$", "coin", Translate::SellChow2, ItemType::coin, 298);
		AddRequirement(s.requirements, "blob", "bigfoodcan", name(Translate::ScrubChowXL), 1);
	}
	{
		SaleItem s(shop.items, name(Translate::BanditPistol), "$icon_banditpistol$", "banditpistol", desc(Translate::BanditPistol));
		AddRequirement(s.requirements, "coin", "", "Coins", 147);
	}
	{
		SaleItem s(shop.items, name(Translate::BanditRifle), "$icon_banditrifle$", "banditrifle", desc(Translate::BanditRifle));
		AddRequirement(s.requirements, "coin", "", "Coins", 190);
	}
	{
		SaleItem s(shop.items, name(Translate::BanditAmmo)+" (5)", "$icon_banditammo$", "mat_banditammo", desc(Translate::BanditAmmo), ItemType::material, 5);
		AddRequirement(s.requirements, "coin", "", "Coins", 21);
	}
	{
		SaleItem s(shop.items, name(Translate::Faultymine), "$faultymine$", "faultymine", desc(Translate::Faultymine));
		AddRequirement(s.requirements, "coin", "", "Coins", 33);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("MigrantHmm");
	this.getSprite().PlaySound("ChaChing");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	Shop@ shop;
	if (!this.get("shop", @shop)) return;

	const bool canChangeClass = caller.getName() != this.get_string("required class") && caller.getTeamNum() >= getRules().getTeamsCount();
	shop.button_offset = canChangeClass ? Vec2f(6, 0) : Vec2f_zero;
}
