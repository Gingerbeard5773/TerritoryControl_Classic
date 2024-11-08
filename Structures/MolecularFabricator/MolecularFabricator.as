#include "MakeCrate.as";
#include "Requirements.as";
#include "ShopCommon.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-25); //background
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", "Molecular Fabricator");
	this.set_u8("shop icon", 15);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	{
		ShopItem@ s = addShopItem(this, "Deconstruct 10 Plasteel Sheets", "$icon_matter_0$", "mat_matter-10", "Deconstruct 10 Plasteel Sheets into 10 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 10);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Deconstruct a Busted Scyther Component", "$icon_matter_1$", "mat_matter-25", "Deconstruct 1 Busted Scyther Component into 25 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "scythergib", "Busted Scyther Component", 1);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 5);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Deconstruct a Charge Rifle", "$icon_matter_1$", "mat_matter-150", "Deconstruct 1 Charge Rifle into 150 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "chargerifle", "Charge Rifle", 1);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 20);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Deconstruct a Charge Lance", "$icon_matter_2$", "mat_matter-200", "Deconstruct 1 Charge Lance into 200 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "chargelance", "Charge Lance", 1);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 20);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Deconstruct an Exosuit", "$icon_matter_3$", "mat_matter-250", "Deconstruct 1 Exosuit into 250 units of Amazing Technicolor Dust.");
		AddRequirement(s.requirements, "blob", "exosuititem", "Exosuit", 1);
		// AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 25);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Reconstruct 10 Plasteel Sheets", "$icon_plasteel$", "mat_plasteel-10", "A durable yet lightweight material.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 10);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 1);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Busted Scyther Component", "$icon_scythergib$", "scythergib", "A completely useless garbage, brand new.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 25);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Charge Rifle", "$icon_chargerifle$", "chargerifle", "A burst-fire energy weapon.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 150);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 25);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Charge Lance", "$icon_chargelance$", "chargelance", "An extremely powerful rail-assisted handheld cannon.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 200);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 35);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct an Exosuit", "$icon_exosuit$", "exosuititem", "A standard issue Model II Exosuit.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 250);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 20);
		s.spawnNothing = true;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Transmute Stone to Iron", "$icon_iron$", "mat_iron-250", "Transmute 250 Stone into 250 Iron Ore.");
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 35);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Transmute Iron to Copper", "$icon_copper$", "mat_copper-250", "Transmute 250 Iron Ore into 250 Copper Ore.");
		AddRequirement(s.requirements, "blob", "mat_iron", "Iron Ore", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Transmute Copper to Gold", "$mat_gold$", "mat_gold-250", "Transmute 250 Copper Ore into 250 Gold Ore.");
		AddRequirement(s.requirements, "blob", "mat_copper", "Copper Ore", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 135);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Transmute Gold to Mithril", "$icon_mithril$", "mat_mithril-250", "Transmute 250 Gold Ore into 250 Mithril Ore.");
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Refine Mithril", "$icon_mithrilingot$", "mat_mithrilingot-2", "Refine 10 Mithril Ore into 2 Mithril Ingots.");
		AddRequirement(s.requirements, "blob", "mat_mithril", "Mithril Ore", 10);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct 10 Metal Rods", "$mat_lancerod$", "mat_lancerod-10", "A bundle of 10 tungsten rods.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 20);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Scyther", "$scyther$", "scyther", "A light combat mechanoid equipped with a Charge Lance.");
		AddRequirement(s.requirements, "blob", "scythergib", "Busted Scyther Component", 5);
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 50);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 25);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 5);
		AddRequirement(s.requirements, "blob", "chargelance", "Charge Lance", 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Reconstruct a Portable Molecular Fabricator", "$icon_molecularfabricator$", "molecularfabricator", "A highly advanced machine capable of restructuring molecules and atoms.");
		AddRequirement(s.requirements, "blob", "mat_matter", "Amazing Technicolor Dust", 25);
		AddRequirement(s.requirements, "blob", "mat_plasteel", "Plasteel Sheet", 10);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", "Mithril Ingot", 2);
		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", caller.getDistanceTo(this) < this.getRadius());
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("MolecularFabricator_Create.ogg");
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
	else if (spl[0] == "scyther")
	{
		CBlob@ crate = server_MakeCrate("scyther", "Scyther Construction Kit", 0, caller.getTeamNum(), this.getPosition(), false);
		crate.Tag("plasteel crate");
		crate.Init();
		caller.server_Pickup(crate);
	}
	else if (spl[0] == "molecularfabricator")
	{
		CBlob@ crate = server_MakeCrate("molecularfabricator", "Molecular Fabricator Construction Kit", 0, caller.getTeamNum(), this.getPosition(), false);
		crate.Tag("plasteel crate");
		crate.Init();
		caller.server_Pickup(crate);
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
