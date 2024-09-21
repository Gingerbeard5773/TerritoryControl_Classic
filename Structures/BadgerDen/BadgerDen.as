// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(500); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");

	this.getCurrentScript().tickFrequency = 300;
	
	this.getShape().SetOffset(Vec2f(0, 4));
	
	this.set_Vec2f("shop offset", Vec2f(4, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "Badger Den");
	this.set_u8("shop icon", 25);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);

	{
		ShopItem@ s = addShopItem(this, "Sell a Steak (1)", "$steak$", "coin-100", "Groo. <3");
		AddRequirement(s.requirements, "blob", "steak", "Steak", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Buy a Friend (1)", "$heart$", "friend", "Moo. >:(");
		AddRequirement(s.requirements, "coin", "", "Coins", 6666);
		AddRequirement(s.requirements, "blob", "steak", "Steak", 3);
		AddRequirement(s.requirements, "blob", "heart", "Heart", 2);
		AddRequirement(s.requirements, "blob", "cake", "Cinnamon bun",1);
		s.spawnNothing = true;
	}
	u16[] spawnedIDs;
	this.set("blobIDs", spawnedIDs);
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	if (XORRandom(100) >= 50) return;

	u16[] spawnedIDs;
	this.get("blobIDs", spawnedIDs);

	for (int i = 0; i < spawnedIDs.length; i++)
	{
		CBlob@ blob = getBlobByNetworkID(spawnedIDs[i]);
		if (blob is null || blob.hasTag("dead"))
		{
			this.removeAt("blobIDs", i);
		}
	}
	
	this.get("blobIDs", spawnedIDs);
	if (spawnedIDs.length < 3)
	{
		CBlob@ blob = server_CreateBlob("badger", -1, this.getPosition());
		if (blob !is null)
		{
			this.push("blobIDs", blob.getNetworkID());
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", (caller.getPosition() - this.getPosition()).Length() < 40.0f);
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
	else if (spl[0] == "friend")
	{
		string friend = spl[0].replace("rien", "sche").replace("f", "").replace("ch", "cy").replace("d", "er").replace("ee", "the");
		CBlob@ blob = server_CreateBlob(friend, caller.getTeamNum(), this.getPosition());
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
		this.getSprite().PlaySound("badger_growl" + (XORRandom(6) + 1) + ".ogg");
	}
}
