// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

const string[] resources = 
{
	"mat_pistolammo",
	"mat_rifleammo",
	"mat_shotgunammo",
	"mat_gatlingammo"
};

const u8[] resourceYields = 
{
	3,
	2,
	2,
	5
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.getSprite().SetZ(-50); //background
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("builder always hit");
	this.Tag("has window");
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	this.getCurrentScript().tickFrequency = 300;
	this.inventoryButtonPos = Vec2f(-8, 0);
	
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 4));
	this.set_string("shop description", name(Translate::Gunsmith)+" ");
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, name(Translate::LowCalAmmo)+" (20)", "$icon_pistolammo$", "mat_pistolammo-20", desc(Translate::LowCalAmmo));
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::HighCalAmmo)+" (5)", "$icon_rifleammo$", "mat_rifleammo-5", desc(Translate::HighCalAmmo));
		AddRequirement(s.requirements, "coin", "", "Coins", 45);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::ShotgunAmmo)+" (4)", "$icon_shotgunammo$", "mat_shotgunammo-4", desc(Translate::ShotgunAmmo));
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::MachinegunAmmo)+" (30)", "$icon_gatlingammo$", "mat_gatlingammo-30", desc(Translate::MachinegunAmmo));
		AddRequirement(s.requirements, "coin", "", "Coins", 80);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Revolver), "$icon_revolver$", "revolver", desc(Translate::Revolver));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 40);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 40);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Rifle), "$icon_rifle$", "rifle", desc(Translate::Rifle));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 60);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::SMG), "$icon_smg$", "smg", desc(Translate::SMG));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Bazooka), "$icon_bazooka$", "bazooka", desc(Translate::Bazooka));
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", name(Translate::CopperIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Scorcher), "$icon_flamethrower$", "flamethrower", desc(Translate::Scorcher));
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 5);
		AddRequirement(s.requirements, "blob", "mat_copperingot", name(Translate::CopperIngot), 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Shotgun), "$icon_shotgun$", "shotgun", desc(Translate::Shotgun));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 70);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 3);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	if (isServer())
	{
		const u8 index = XORRandom(resources.length);
		if (!this.getInventory().isFull())
		{
			Material::createFor(this, resources[index], XORRandom(resourceYields[index]));
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this) && forBlob.getCarriedBlob() is null;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", caller.getDistanceTo(this) < this.getRadius());
	if (isInventoryAccessible(this, caller))
	{
		this.set_Vec2f("shop offset", Vec2f(4, 0));
	}
	else
	{
		this.set_Vec2f("shop offset", Vec2f(0, 0));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("ConstructShort.ogg");
	}
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
