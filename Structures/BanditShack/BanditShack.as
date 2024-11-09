// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
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
	
	this.set_Vec2f("shop offset", Vec2f(4, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", Translate::RatDen);
	this.set_u8("shop icon", 25);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	{
		ShopItem@ s = addShopItem(this, name(Translate::RatBurger), "$ratburger$", "ratburger", desc(Translate::RatBurger));
		AddRequirement(s.requirements, "coin", "", "Coins", 31);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::RatFood), "$ratfood$", "ratfood", desc(Translate::RatFood));
		AddRequirement(s.requirements, "coin", "", "Coins", 17);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, "Some Badger", "$badger$", "badger", "I found ths guy under my bed.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
	}*/
	{
		ShopItem@ s = addShopItem(this, sell(Translate::ScrubChow, "1"), "$COIN$", "coin-29", Translate::SellChow.replace("{COINS}", "29"));
		AddRequirement(s.requirements, "blob", "foodcan", name(Translate::ScrubChow), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, sell(Translate::ScrubChowXL, "1"), "$COIN$", "coin-298", Translate::SellChow2);
		AddRequirement(s.requirements, "blob", "bigfoodcan", name(Translate::ScrubChowXL), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::BanditPistol), "$icon_banditpistol$", "banditpistol", desc(Translate::BanditPistol));
		AddRequirement(s.requirements, "coin", "", "Coins", 147);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, name(Translate::BanditRifle), "$icon_banditrifle$", "banditrifle", desc(Translate::BanditRifle));
		AddRequirement(s.requirements, "coin", "", "Coins", 190);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::BanditAmmo)+" (5)", "$icon_banditammo$", "mat_banditammo-5", desc(Translate::BanditAmmo));
		AddRequirement(s.requirements, "coin", "", "Coins", 21);
		s.spawnNothing = true;
	}*/
	{
		ShopItem@ s = addShopItem(this, "Lite Pistal Bullets (5)", "$icon_pistolammo$", "mat_pistolammo-5", "My grandpa made these bullets.");
		AddRequirement(s.requirements, "coin", "", "Coins", 38);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Faultymine), "$faultymine$", "faultymine", desc(Translate::Faultymine));
		AddRequirement(s.requirements, "coin", "", "Coins", 33);
		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	const bool canChangeClass = caller.getName() != this.get_string("required class") && caller.getTeamNum() >= getRules().getTeamsCount();
	
	if (canChangeClass)
	{
		this.set_Vec2f("shop offset", Vec2f(6, 0));
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f_zero);
	}
	
	this.set_bool("shop available", caller.getDistanceTo(this) < this.getRadius());
}

void onShopMadeItem(CBitStream@ params)
{
	if (!isServer()) return;

	u16 this_id, caller_id, item_id;
	string name;

	if (!params.saferead_u16(this_id) || !params.saferead_u16(caller_id) || !params.saferead_u16(item_id) || !params.saferead_string(name))
	{
		return;
	}
	
	CBlob@ this = getBlobByNetworkID(this_id);
	if (this is null) return;

	CBlob@ caller = getBlobByNetworkID(caller_id);
	if (caller is null) return;

	string[] spl = name.split("-");
	if (spl[0] == "coin")
	{
		CPlayer@ callerPlayer = caller.getPlayer();
		if (callerPlayer is null) return;

		callerPlayer.server_setCoins(callerPlayer.getCoins() +  parseInt(spl[1]));
	}
	else if (name.findFirst("mat_") != -1)
	{
		Material::createFor(caller, spl[0], parseInt(spl[1]));
	}
	else
	{
		CBlob@ blob = server_CreateBlob(spl[0], caller.getTeamNum(), this.getPosition());
		if (blob is null) return;
		if (!blob.canBePutInInventory(caller))
		{
			caller.server_Pickup(blob);
		}
		else if (caller.getInventory() !is null && !caller.getInventory().isFull())
		{
			caller.server_PutInInventory(blob);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("MigrantHmm");
		this.getSprite().PlaySound("ChaChing");
	}
}
