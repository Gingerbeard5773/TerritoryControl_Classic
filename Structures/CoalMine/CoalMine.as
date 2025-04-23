// Coal Mine

#include "Requirements.as";
#include "StoreCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

const string[] resources = 
{
	"mat_coal",
	"mat_iron",
	"mat_copper",
	"mat_stone",
	"mat_gold",
	"mat_sulphur",
	"mat_dirt"
};

const u8[] resourceYields = 
{
	2,
	27,
	7,
	45,
	20,
	7,
	7
};

void onInit(CBlob@ this)
{
	this.Tag("teamlocked tunnel");
	this.Tag("ignore raid");
	this.Tag("change team on fort capture");
	
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 0.0f));
	this.set_Vec2f("travel button pos", Vec2f(3.5f, 4));
	this.inventoryButtonPos = Vec2f(-16, 8);
	this.getCurrentScript().tickFrequency = 30*5;

	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	this.setInventoryName(Translate::CoalMine);
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, Translate::CoalMine);
	shop.menu_size = Vec2f(3, 2);
	shop.button_offset = Vec2f(3, -2);
	shop.button_icon = 25;

	{
		SaleItem s(shop.items, buy(Translate::Dirt, "100"), "$icon_dirt$", "mat_dirt", buy(Translate::Dirt, "100", "100"), ItemType::material, 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		SaleItem s(shop.items, buy("Stone", "250"), "$mat_stone$", "mat_stone", buy("Stone", "250", "125"), ItemType::normal, 250);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
	}
	{
		SaleItem s(shop.items, buy(Translate::Coal, "10"), "$icon_coal$", "mat_coal", buy(Translate::Coal, "10", "150"), ItemType::material, 10);
		AddRequirement(s.requirements,"coin", "", "Coins", 150); //made it cost a lot, so it's better to just conquer the building
	}
	{
		SaleItem s(shop.items, buy(Translate::CopperOre, "100"), "$icon_copper$", "mat_copper", buy(Translate::CopperOre, "100", "120"), ItemType::material, 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
	}
	{
		SaleItem s(shop.items, buy(Translate::IronOre, "100"), "$icon_iron$", "mat_iron", buy(Translate::IronOre, "100", "100"), ItemType::material, 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		SaleItem s(shop.items, buy(Translate::Sulphur, "50"), "$icon_sulphur$", "mat_sulphur", buy(Translate::Sulphur, "50", "150"), ItemType::material, 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("/ChaChing.ogg");
	
	if (isServer() && blob !is null && item.blob_name == "mat_stone")
	{
		blob.Tag("no stone gold");
		blob.server_SetQuantity(item.quantity);
	}
}

void onTick(CBlob@ this)
{
	if (isServer())
	{	
		CBlob@ storage = FindStorage(this.getTeamNum());
		const u8 index = XORRandom(resources.length);
		
		if (storage !is null)
		{
			Material::createFor(storage, resources[index], XORRandom(resourceYields[index]));
		}
		else if (!this.getInventory().isFull())
		{
			Material::createFor(this, resources[index], XORRandom(resourceYields[index]));
		}
	}
}

CBlob@ FindStorage(u8 team)
{
	if (team >= getRules().getTeamsCount()) return null;
	
	CBlob@[] blobs;
	getBlobsByName("stonepile", @blobs);
	
	CBlob@[] validBlobs;
	
	for (u32 i = 0; i < blobs.length; i++)
	{
		if (blobs[i].getTeamNum() == team && !blobs[i].getInventory().isFull())
		{
			validBlobs.push_back(blobs[i]);
		}
	}
	
	if (validBlobs.length == 0) return null;

	return validBlobs[XORRandom(validBlobs.length)];
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this);
}
