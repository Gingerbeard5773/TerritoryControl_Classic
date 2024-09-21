#include "StandardRespawnCommand.as";
#include "Requirements.as";
#include "ShopCommon.as";
#include "FactionBuildingCommon.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore extractor");

	this.set_TileType("background tile", CMap::tile_castle_back);

	this.addCommandID("sv_store");

	this.Tag("minimap_large");
	this.set_u8("minimap_index", 2);

	this.set_Vec2f("travel button pos", Vec2f(0.5f, 0));

	// Respawning & class changing
	this.Tag("respawn");
	InitClasses(this);

	// Inventory
	this.Tag("change class store inventory");
	this.inventoryButtonPos = Vec2f(28, -5);

	server_SetFloor(this, CMap::tile_castle);

	// Upgrading stuff
	this.set_Vec2f("shop offset", Vec2f(-24, 10));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "Upgrades & Repairs");
	this.set_u8("shop icon", 15);

	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);

	{
		ShopItem@ s = addShopItem(this, "Repair", "$icon_repair$", "repair", "Repair this damaged building.\nRestores 5% of building's integrity.");	
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 200);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		s.customButton = true;
		s.buttonwidth = 2;	
		s.buttonheight = 2;
		s.spawnNothing = true;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getTeamNum() == this.getTeamNum() && caller.isOverlapping(this))
	{
		caller.CreateGenericButton("$change_class$", Vec2f(-12, -2.5f), this, buildSpawnMenu, getTranslatedString("Change class"));

		CInventory@ inv = caller.getInventory();
		if (inv is null) return;

		if (inv.getItemsCount() > 0)
		{
			CButton@ buttonOwner = caller.CreateGenericButton(28, Vec2f(14, 5), this, this.getCommandID("sv_store"), "Store");
		}
	}
	this.set_bool("shop available", caller.isOverlapping(this));
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
	
	if (name == "repair")
	{
		this.getSprite().PlaySound("/ConstructShort.ogg");
		
		const f32 heal = this.getInitialHealth() * 0.05f;
		this.server_SetHealth(Maths::Min(this.getHealth() + heal, this.getInitialHealth()));
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);

	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("/ConstructShort.ogg");
	}
	else if (cmd == this.getCommandID("sv_store") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		CBlob@ caller = player.getBlob();
		if (caller is null) return;

		CBlob@ carried = caller.getCarriedBlob();
		if (carried !is null && carried.hasTag("temp blob"))
		{
			carried.server_Die();
		}

		CInventory@ inv = caller.getInventory();
		if (inv !is null)
		{
			while (inv.getItemsCount() > 0)
			{
				CBlob @item = inv.getItem(0);
				caller.server_PutOutInventory(item);
				this.server_PutInInventory(item);
			}
		}
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (forBlob.getTeamNum() == this.getTeamNum() && forBlob.isOverlapping(this));
}
