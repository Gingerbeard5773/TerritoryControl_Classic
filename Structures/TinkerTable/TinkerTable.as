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

	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	this.getCurrentScript().tickFrequency = 150;
	
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", name(Translate::Mechanist));
	this.set_u8("shop icon", 15);
	
	{
		ShopItem@ s = addShopItem(this, "Drill", "$drill$", "drill", Descriptions::drill, false);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Gramophone), "$gramophone$", "gramophone", desc(Translate::Gramophone));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Saw", "$saw$", "saw", Descriptions::saw, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::PowerDrill), "$powerdrill$", "powerdrill", desc(Translate::PowerDrill));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 2);
		AddRequirement(s.requirements, "blob", "mat_copperwire", name(Translate::CopperWire), 2);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Contrabass), "$contrabass$", "contrabass", desc(Translate::Contrabass));
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 60);
		AddRequirement(s.requirements, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::CopperWire)+" (2)", "$mat_copperwire$", "mat_copperwire-2", desc(Translate::CopperWire));
		AddRequirement(s.requirements, "blob", "mat_copperingot", name(Translate::CopperIngot), 1);
		s.spawnNothing = true;
	}	
	{
		ShopItem@ s = addShopItem(this, name(Translate::Klaxon), "$icon_klaxon$", "klaxon", desc(Translate::Klaxon));
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 666);
		s.spawnNothing = true;
	}	
	{
		ShopItem@ s = addShopItem(this, name(Translate::Automat), "$icon_automat$", "automat", desc(Translate::Automat));
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 4);
		AddRequirement(s.requirements, "blob", "fishy", "Fishy", 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 750);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::GasExtractor), "$icon_gasextractor$", "gasextractor", desc(Translate::GasExtractor));
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 2);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 1);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 80);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 1;
		s.spawnNothing = true;
	}
	/*{
		ShopItem@ s = addShopItem(this, name(Translate::MustardGas), "$icon_mustard$", "mat_mustard-50", desc(Translate::MustardGas));
		AddRequirement(s.requirements, "blob", "mat_sulphur", Translate::Sulphur, 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}*/
	{
		ShopItem@ s = addShopItem(this, name(Translate::Jetpack), "$icon_jetpack$", "jetpack", desc(Translate::Jetpack));
		AddRequirement(s.requirements, "blob", "mat_smallrocket", name(Translate::SmallRocket), 2);
		AddRequirement(s.requirements, "blob", "mat_oil", Translate::Oil, 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::ScubaGear), "$icon_scubagear$", "scubagear", desc(Translate::ScubaGear));
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 1);
		AddRequirement(s.requirements, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.spawnNothing = true;
	}
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	CBlob@[] blobs;
	getMap().getBlobsInBox(this.getPosition() + Vec2f(96, 64), this.getPosition() + Vec2f(-96, 0), @blobs);
	for (u16 i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (!blob.hasTag("vehicle") || blob.getHealth() >= blob.getInitialHealth()) continue;

		blob.server_Heal(1);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(2,0));
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
