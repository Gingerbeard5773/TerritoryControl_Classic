#include "MakeCrate.as";
#include "Requirements.as";
#include "StoreCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetZ(-25); //background

	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, name(Translate::Fabricator));
	shop.menu_size = Vec2f(5, 4);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 15;

	{
		SaleItem s(shop.items, deconstruct("10 "+name(Translate::Plasteel)), "$icon_matter_0$", "mat_matter", transmute2(name(Translate::Plasteel), "10", Translate::Matter, "10"), ItemType::material, 10);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 10);
	}
	{
		SaleItem s(shop.items, deconstruct(name(Translate::BustedScyther)), "$icon_matter_1$", "mat_matter", transmute2(name(Translate::BustedScyther), "1", Translate::Matter, "25"), ItemType::material, 25);
		AddRequirement(s.requirements, "blob", "scythergib", name(Translate::BustedScyther), 1);
	}
	{
		SaleItem s(shop.items, deconstruct(name(Translate::ChargeRifle)), "$icon_matter_1$", "mat_matter", transmute2(name(Translate::ChargeRifle), "1", Translate::Matter, "150"), ItemType::material, 150);
		AddRequirement(s.requirements, "blob", "chargerifle", name(Translate::ChargeRifle), 1);
	}
	{
		SaleItem s(shop.items, deconstruct(name(Translate::ChargeLance)), "$icon_matter_2$", "mat_matter", transmute2(name(Translate::ChargeLance), "1", Translate::Matter, "200"), ItemType::material, 200);
		AddRequirement(s.requirements, "blob", "chargelance", name(Translate::ChargeLance), 1);
	}
	{
		SaleItem s(shop.items, deconstruct(name(Translate::Exosuit)), "$icon_matter_3$", "mat_matter", transmute2(name(Translate::Exosuit), "1", Translate::Matter, "250"), ItemType::material, 250);
		AddRequirement(s.requirements, "blob", "exosuititem", name(Translate::Exosuit), 1);
	}
	{
		SaleItem s(shop.items, reconstruct("10 "+name(Translate::Plasteel)), "$icon_plasteel$", "mat_plasteel", desc(Translate::Plasteel), ItemType::material, 10);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 10);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 1);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 1);
	}
	{
		SaleItem s(shop.items, reconstruct(name(Translate::BustedScyther)), "$icon_scythergib$", "scythergib", desc(Translate::BustedScyther));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 25);
		AddRequirement(s.requirements, "blob", "mat_steelingot", name(Translate::SteelIngot), 2);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 1);
	}
	{
		SaleItem s(shop.items, reconstruct(name(Translate::ChargeRifle)), "$icon_chargerifle$", "chargerifle", desc(Translate::ChargeRifle));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 150);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 25);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 10);
	}
	{
		SaleItem s(shop.items, reconstruct(name(Translate::ChargeLance)), "$icon_chargelance$", "chargelance", desc(Translate::ChargeLance));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 200);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 35);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 10);
	}
	{
		SaleItem s(shop.items, reconstruct(name(Translate::Exosuit)), "$icon_exosuit$", "exosuititem", desc(Translate::Exosuit));
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 250);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 20);
	}
	{
		SaleItem s(shop.items, transmute("Stone", Translate::IronOre), "$icon_iron$", "mat_iron", transmute2("Stone", "250", Translate::IronOre, "250"), ItemType::material, 250);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 35);
	}
	{
		SaleItem s(shop.items, transmute(Translate::IronOre, Translate::CopperOre), "$icon_copper$", "mat_copper", transmute2(Translate::IronOre, "250", Translate::CopperOre, "250"), ItemType::material, 250);
		AddRequirement(s.requirements, "blob", "mat_iron", Translate::IronOre, 250);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 10);
	}
	{
		SaleItem s(shop.items, transmute(Translate::CopperOre, "Gold Ore"), "$mat_gold$", "mat_gold", transmute2(Translate::CopperOre, "250", "Gold Ore", "250"), ItemType::material, 250);
		AddRequirement(s.requirements, "blob", "mat_copper", Translate::CopperOre, 250);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 135);
	}
	{
		SaleItem s(shop.items, transmute("Gold Ore", Translate::MithrilOre), "$icon_mithril$", "mat_mithril", transmute2("Gold Ore", "250", Translate::MithrilOre, "250"), ItemType::material, 250);
		AddRequirement(s.requirements, "blob", "mat_gold", "Gold Ore", 250);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 50);
	}
	{
		SaleItem s(shop.items, Translate::MithrilIngot +" (2)", "$icon_mithrilingot$", "mat_mithrilingot", transmute2(Translate::MithrilOre, "10", Translate::MithrilIngot, "2"), ItemType::material, 2);
		AddRequirement(s.requirements, "blob", "mat_mithril", Translate::MithrilOre, 10);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 10);
	}
	{
		SaleItem s(shop.items, reconstruct("10 "+name(Translate::LanceRod)), "$mat_lancerod$", "mat_lancerod", desc(Translate::LanceRod), ItemType::material, 10);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 20);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 1);
	}
	{
		SaleItem s(shop.items, reconstruct(name(Translate::Scyther)), "$scyther$", "scyther", desc(Translate::Scyther), ItemType::nothing);
		AddRequirement(s.requirements, "blob", "scythergib", name(Translate::BustedScyther), 5);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 50);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 25);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 5);
		AddRequirement(s.requirements, "blob", "chargelance", name(Translate::ChargeLance), 1);
	}
	{
		SaleItem s(shop.items, reconstruct(name(Translate::Fabricator)), "$icon_molecularfabricator$", "molecularfabricator", desc(Translate::Fabricator), ItemType::nothing);
		AddRequirement(s.requirements, "blob", "mat_matter", Translate::Matter, 25);
		AddRequirement(s.requirements, "blob", "mat_plasteel", name(Translate::Plasteel), 10);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 2);
	}
}

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

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("MolecularFabricator_Create.ogg");

	if (isServer())
	{
		if (item.blob_name == "scyther")
		{
			CBlob@ crate = server_MakeCrate("scyther", "Scyther Construction Kit", 0, caller.getTeamNum(), this.getPosition(), false);
			crate.Tag("plasteel crate");
			crate.Init();
			caller.server_Pickup(crate);
		}
		else if (item.blob_name == "molecularfabricator")
		{
			CBlob@ crate = server_MakeCrate("molecularfabricator", "Molecular Fabricator Construction Kit", 0, caller.getTeamNum(), this.getPosition(), false);
			crate.Tag("plasteel crate");
			crate.Init();
			caller.server_Pickup(crate);
		}
	}
}
