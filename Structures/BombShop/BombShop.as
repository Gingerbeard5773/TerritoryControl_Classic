// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("builder always hit");
	this.Tag("has window");
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 5));
	this.set_string("shop description", "Demolitionist's Workshop");
	this.set_u8("shop icon", 15);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	{
		ShopItem@ s = addShopItem(this, "Artillery Shell (4)", "$icon_tankshell$", "mat_tankshell-4", "A highly explosive shell used by the artillery.");
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Howitzer Shell (2)", "$icon_howitzershell$", "mat_howitzershell-2", "A large howitzer shell capable of annihilating a cottage.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Rocket of Doom", "$icon_rocket$", "rocket", "Let's fly to the Moon. (Not really)");
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_coal", "Coal", 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "S.Y.L.W. 9000 (1)", "$icon_bigbomb$", "mat_bigbomb-1", "A big bomb. Handle with care.");
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		s.customButton = true;
		s.buttonwidth = 1;
		s.buttonheight = 2;
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Mine", "$mine$", "mine", Descriptions::mine, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Fragmentation Mine", "$icon_fragmine$", "fragmine", "A fragmentation mine that fills the surroundings with shards of metal upon detonation.");
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb (1)", "$bomb$", "mat_bombs-1", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrow (1)", "$mat_bombarrows$", "mat_bombarrows-1", Descriptions::bombarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Small Bomb (4)", "$icon_smallbomb$", "mat_smallbomb-4", "A small iron bomb. Detonates when it hits surface with enough force.");
		AddRequirement(s.requirements, "coin", "", "Coins", 130);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Incendiary Bomb (1)", "$icon_incendiarybomb$", "mat_incendiarybomb-1", "Sets the peasants on fire.");
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		AddRequirement(s.requirements, "blob", "mat_oil", "Oil", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, "Bunker Buster (1)", "$icon_bunkerbuster$", "mat_bunkerbuster-1", "Perfect for making holes in heavily fortified bases. Detonates upon strong impact.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Shockwave Bomb (2)", "$icon_stunbomb$", "mat_stunbomb-1", "Creates a shockwave with strong knockback. Detonates upon strong impact.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_methane", "Methane", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Grenade (2)", "$icon_grenade$", "mat_grenade-2", "A small, timed explosive device used by grenade launchers.");
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		s.spawnNothing = true;
	}*/
	{
		ShopItem@ s = addShopItem(this, "R.O.F.L. (1)", "$icon_nuke$", "nuke", "A dangerous warhead stuffed in a cart. Since it's heavy, it can be only pushed around or picked up by balloons.");
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 40);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 20);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100); // Cart!
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gregor (1)", "$icon_claymore$", "claymore-1", "A remotely triggered explosive device covered in some sort of slime. Sticks to surfaces.");
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Small Rocket (1)", "$icon_smallrocket$", "mat_smallrocket-1", "Self-propelled ammunition for rocket launchers.");
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Gregor Remote Detonator", "$icon_claymoreremote$", "claymoreremote-1", "A device used to remotely detonate Gregors.");
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, "Smoke Grenade", "$icon_smokegrenade$", "mat_smokegrenade-1", "A small hand grenade used to quickly fill a room with smoke. It helps you keep out of sight.");
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_sulphur", "Sulphur", 25);
		s.spawnNothing = true;
	}*/
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_bool("shop available", this.isOverlapping(caller));
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
		if (caller.getPlayer() !is null && name == "nuke")
		{
			blob.SetDamageOwnerPlayer(caller.getPlayer());
		}
		
		if (!blob.hasTag("vehicle"))
		{
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
}
