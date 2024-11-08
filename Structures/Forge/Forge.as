// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("builder always hit");

	this.set_Vec2f("shop offset", Vec2f(0,1));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Forge");
	this.set_u8("shop icon", 15);

	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	{
		ShopItem@ s = addShopItem(this, "Copper Ingot (1)", "$icon_copperingot$", "mat_copperingot-1", "A soft conductive metal.", true);
		AddRequirement(s.requirements, "blob", "mat_copper", "Copper Ore", 10);
		// AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 1);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Iron Ingot (1)", "$icon_ironingot$", "mat_ironingot-1", "A fairly strong metal used to make tools, equipment and such.", true);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron Ore", 10);
		// AddRequirement(s.requirements, "blob", "mat_coal", "Coal",1);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Steel Ingot (1)", "$icon_steelingot$", "mat_steelingot-1", "Much stronger than iron, but also more expensive.", true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 1);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Gold Ingot (1)", "$icon_goldingot$", "mat_goldingot-1", "A fancy metal - traders' favourite.", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 25);
		// AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 1);
		s.spawnNothing = true;
	}
	
	// Large batch
	{
		ShopItem@ s = addShopItem(this, "Copper Ingot (4)", "$icon_copperingot$", "mat_copperingot-4", "A soft conductive metal.", true);
		AddRequirement(s.requirements, "blob", "mat_copper", "Copper Ore", 40);
		// AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 4);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Iron Ingot (4)", "$icon_ironingot$", "mat_ironingot-4", "A fairly strong metal used to make tools, equipment and such.", true);
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron Ore", 40);
		// AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 4);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Steel Ingot (4)", "$icon_steelingot$", "mat_steelingot-4", "Much stronger than iron, but also more expensive.", true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 16);
		AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 4);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Gold Ingot (4)", "$icon_goldingot$", "mat_goldingot-4", "A fancy metal - traders' favourite.", true);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 100);
		// AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 4);
		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(2,0));
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
		this.getSprite().PlaySound("ConstructShort.ogg");
	}
}
