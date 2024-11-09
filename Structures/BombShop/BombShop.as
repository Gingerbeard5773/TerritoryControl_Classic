// A script by TFlippy

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("builder always hit");
	this.Tag("has window");
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(4, 6));
	this.set_string("shop description", name(Translate::Bombshop));
	this.set_u8("shop icon", 15);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	{
		ShopItem@ s = addShopItem(this, name(Translate::TankShell)+" (4)", "$icon_tankshell$", "mat_tankshell-4", desc(Translate::TankShell));
		AddRequirement(s.requirements, "coin", "", "Coins", 60);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::HowitzerShell)+" (2)", "$icon_howitzershell$", "mat_howitzershell-2", desc(Translate::HowitzerShell));
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Rocket), "$icon_rocket$", "rocket", desc(Translate::Rocket));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_coal", Translate::Coal, 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::BigBomb), "$icon_bigbomb$", "mat_bigbomb-1", desc(Translate::BigBomb));
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
		ShopItem@ s = addShopItem(this, name(Translate::Fragmine), "$icon_fragmine$", "fragmine", desc(Translate::Fragmine));
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb", "$bomb$", "mat_bombs-1", Descriptions::bomb, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Bomb Arrow", "$mat_bombarrows$", "mat_bombarrows-1", Descriptions::bombarrows, true);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::SmallBomb)+" (4)", "$icon_smallbomb$", "mat_smallbomb-4", desc(Translate::SmallBomb));
		AddRequirement(s.requirements, "coin", "", "Coins", 130);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::IncendiaryBomb), "$icon_incendiarybomb$", "mat_incendiarybomb-1", desc(Translate::IncendiaryBomb));
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		AddRequirement(s.requirements, "blob", "mat_oil", Translate::Oil, 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Keg", "$keg$", "keg", Descriptions::keg, false);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, name(Translate::BunkerBuster), "$icon_bunkerbuster$", "mat_bunkerbuster-1", desc(Translate::BunkerBuster));
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_sulphur", Translate::Sulphur, 25);
		s.spawnNothing = true;
	}*/
	{
		ShopItem@ s = addShopItem(this, name(Translate::StunBomb)+" (2)", "$icon_stunbomb$", "mat_stunbomb-2", desc(Translate::StunBomb));
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_methane", Translate::Methane, 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Nuke), "$icon_nuke$", "nuke", desc(Translate::Nuke));
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 40);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 20);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100); // Cart!
		AddRequirement(s.requirements, "coin", "", "Coins", 2000);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Claymore), "$icon_claymore$", "claymore-1", desc(Translate::Claymore));
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::SmallRocket), "$icon_smallrocket$", "mat_smallrocket-1", desc(Translate::SmallRocket));
		AddRequirement(s.requirements, "coin", "", "Coins", 70);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::ClaymoreRemote), "$icon_claymoreremote$", "claymoreremote-1", desc(Translate::ClaymoreRemote));
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, name(Translate::SmokeGrenade), "$icon_smokegrenade$", "mat_smokegrenade-1", desc(Translate::SmokeGrenade));
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		AddRequirement(s.requirements, "blob", "mat_sulphur", Translate::Sulphur, 25);
		s.spawnNothing = true;
	}*/
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f_zero);
	this.set_bool("shop available", caller.getDistanceTo(this) < this.getRadius());
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
