#include "MakeCrate.as";
#include "Requirements.as";
#include "ShopCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-25); //background
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(5, 4));
	this.set_string("shop description", name(Translate::Fabricator));
	this.set_u8("shop icon", 15);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);

	{
		ShopItem@ s = addShopItem(this, deconstruct("10 "+name(Translate::Plasteel)), "$icon_matter_0$", "mat_matter-10", transmute2(name(Translate::Plasteel), "10", Translate::Matter, "10"));
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, deconstruct(name(Translate::BustedScyther)), "$icon_matter_1$", "mat_matter-25", transmute2(name(Translate::BustedScyther), "1", Translate::Matter, "25"));
		AddRequirement(s.requirements, "blob", "scythergib", name(Translate::BustedScyther), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, deconstruct(name(Translate::ChargeRifle)), "$icon_matter_1$", "mat_matter-150", transmute2(name(Translate::ChargeRifle), "1", Translate::Matter, "150"));
		AddRequirement(s.requirements, "blob", "chargerifle", name(Translate::ChargeRifle), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, deconstruct(name(Translate::ChargeLance)), "$icon_matter_2$", "mat_matter-200", transmute2(name(Translate::ChargeLance), "1", Translate::Matter, "200"));
		AddRequirement(s.requirements, "blob", "chargelance", name(Translate::ChargeLance), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, deconstruct(name(Translate::Exosuit)), "$icon_matter_3$", "mat_matter-250", transmute2(name(Translate::Exosuit), "1", Translate::Matter, "250"));
		AddRequirement(s.requirements, "blob", "exosuititem", name(Translate::Exosuit), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, reconstruct("10 "+name(Translate::Plasteel)), "$icon_plasteel$", "mat_plasteel-10", desc(Translate::Plasteel));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 10);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 1);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, reconstruct(name(Translate::BustedScyther)), "$icon_scythergib$", "scythergib", desc(Translate::BustedScyther));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 25);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 2);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, reconstruct(name(Translate::ChargeRifle)), "$icon_chargerifle$", "chargerifle", desc(Translate::ChargeRifle));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 150);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 25);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, reconstruct(name(Translate::ChargeLance)), "$icon_chargelance$", "chargelance", desc(Translate::ChargeLance));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 200);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 35);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, reconstruct(name(Translate::Exosuit)), "$icon_exosuit$", "exosuititem", desc(Translate::Exosuit));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 250);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 20);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, transmute("Stone", Translate::IronOre), "$icon_iron$", "mat_iron-250", transmute2("Stone", "250", Translate::IronOre, "250"));
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 35);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, transmute(Translate::IronOre, Translate::CopperOre), "$icon_copper$", "mat_copper-250", transmute2(Translate::IronOre, "250", Translate::CopperOre, "250"));
		AddRequirement(s.requirements, "blob", "mat_iron", Translate::IronOre, 250);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, transmute(Translate::CopperOre, "Gold Ore"), "$mat_gold$", "mat_gold-250", transmute2(Translate::CopperOre, "250", "Gold Ore", "250"));
		AddRequirement(s.requirements, "blob", "mat_copper", Translate::CopperOre, 250);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 135);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, transmute("Gold Ore", Translate::MithrilOre), "$icon_mithril$", "mat_mithril-250", transmute2("Gold Ore", "250", Translate::MithrilOre, "250"));
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 50);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, Translate::MithrilIngot +" (2)", "$icon_mithrilingot$", "mat_mithrilingot-2", transmute2(Translate::MithrilOre, "10", Translate::MithrilIngot, "2"));
		AddRequirement(s.requirements, "blob", "mat_mithril", Translate::MithrilOre, 10);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 10);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, reconstruct("10 "+name(Translate::LanceRod)), "$mat_lancerod$", "mat_lancerod-10", desc(Translate::LanceRod));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 20);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, reconstruct(name(Translate::Scyther)), "$scyther$", "scyther", desc(Translate::Scyther));
		AddRequirement(s.requirements, "blob", "scythergib", name(Translate::BustedScyther), 5);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 50);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 25);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 5);
		AddRequirement(s.requirements, "blob", "chargelance", name(Translate::ChargeLance), 1);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, reconstruct(name(Translate::Fabricator)), "$icon_molecularfabricator$", "molecularfabricator", desc(Translate::Fabricator));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 25);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 10);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 2);
		s.spawnNothing = true;
	}
}

//this shit is so ass.
string reconstruct(const string&in item)
{
	return Translate::Reconstruct.replace("{ITEM}", getTranslatedString(item));
}

string deconstruct(const string&in item)
{
	return Translate::Deconstruct.replace("{ITEM}", getTranslatedString(item));
}

string transmute(const string&in item, const string&in result)
{
	return Translate::Transmute.replace("{ITEM}", getTranslatedString(item)).replace("{RESULT}", getTranslatedString(result));
}

string transmute2(const string&in item, const string&in quantity, const string&in result, const string&in recieved)
{
	return Translate::Transmute2.replace("{ITEM}", getTranslatedString(item)).replace("{QUANTITY}", quantity).replace("{RESULT}", getTranslatedString(result)).replace("{RECIEVED}", recieved);
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
