// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "StandardRespawnCommand.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("respawn");

	this.Tag("builder always hit");
	
	this.set_string("required class", "bandit");
	this.set_string("required tag", "neutral");
	this.set_Vec2f("class offset", Vec2f(-4, 0));
	
	this.set_Vec2f("shop offset", Vec2f(4, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Rat's Den");
	this.set_u8("shop icon", 25);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	{
		ShopItem@ s = addShopItem(this, "Tasty Rat Burger", "$ratburger$", "ratburger", "I always ate this as a kid.");
		AddRequirement(s.requirements, "coin", "", "Coins", 31);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Very Fresh Rat", "$ratfood$", "ratfood", "I caught this rat myself.");
		AddRequirement(s.requirements, "coin", "", "Coins", 17);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, "Some Badger", "$badger$", "badger", "I found ths guy under my bed.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
	}*/
	{
		ShopItem@ s = addShopItem(this, "Sell Scrub's Chow (1)", "$COIN$", "coin-29", "My favourite meal. I'll give you 29 coins for this!");
		AddRequirement(s.requirements, "blob", "foodcan", "Scrub's Chow", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Sell Scrub's Chow XL (1)", "$COIN$", "coin-298", "My grandma loves this traditional dish.");
		AddRequirement(s.requirements, "blob", "bigfoodcan", "Scrub's Chow XL", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Lite Pistal", "$icon_banditpistol$", "banditpistol", "My grandma made this pistol.");
		AddRequirement(s.requirements, "coin", "", "Coins", 147);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, "Timbr Grindr", "$icon_banditrifle$", "banditrifle", "I jammed two pipes in this and it kills people and works it's good.");
		AddRequirement(s.requirements, "coin", "", "Coins", 190);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Kill Pebles (5)", "$icon_banditammo$", "mat_banditammo-5", "My grandpa made these.");
		AddRequirement(s.requirements, "coin", "", "Coins", 21);
		s.spawnNothing = true;
	}*/
	{
		ShopItem@ s = addShopItem(this, "Lite Pistal Bullets (5)", "$icon_pistolammo$", "mat_pistolammo-5", "My grandpa made these bullets.");
		AddRequirement(s.requirements, "coin", "", "Coins", 38);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "A Working Mine", "$faultymine$", "faultymine", "You should buy this mine.");
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
