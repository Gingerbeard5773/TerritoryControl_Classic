// Coal Mine

#include "Requirements.as";
#include "ShopCommon.as";
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

	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);

	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
	
	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 8));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", Translate::CoalMine);
	this.set_u8("shop icon", 25);
	
	this.setInventoryName(Translate::CoalMine);

	{
		ShopItem@ s = addShopItem(this, buy(Translate::Dirt, "100"), "$icon_dirt$", "mat_dirt-100", buy(Translate::Dirt, "100", "100"));
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, buy("Stone", "250"), "$mat_stone$", "mat_stone-250", buy("Stone", "250", "125"));
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, buy(Translate::Coal, "10"), "$icon_coal$", "mat_coal-10", buy(Translate::Coal, "10", "150"));
		AddRequirement(s.requirements,"coin", "", "Coins", 150); //made it cost a lot, so it's better to just conquer the building
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, buy(Translate::CopperOre, "100"), "$icon_copper$", "mat_copper-100", buy(Translate::CopperOre, "100", "120"));
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, buy(Translate::IronOre, "100"), "$icon_iron$", "mat_iron-100", buy(Translate::IronOre, "100", "100"));
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, buy(Translate::Sulphur, "50"), "$icon_sulphur$", "mat_sulphur-50", buy(Translate::Sulphur, "50", "150"));
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.spawnNothing = true;
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

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(3, -2));
	this.set_bool("shop available", caller.getDistanceTo(this) < this.getRadius());
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this);
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
		
		callerPlayer.server_setCoins(callerPlayer.getCoins() + parseInt(spl[1]));
	}
	else if (name.findFirst("mat_") != -1)
	{
		if (name.findFirst("mat_stone") == -1)
		{
			Material::createFor(caller, spl[0], parseInt(spl[1]));
			return;
		}

		CBlob@ stone = server_CreateBlob(spl[0]);
		if (stone !is null)
		{
			stone.Tag("no stone gold");
			stone.server_SetQuantity(parseInt(spl[1]));
			if (!caller.server_PutInInventory(stone))
			{
				stone.setPosition(caller.getPosition());
			}
		}
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
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}
