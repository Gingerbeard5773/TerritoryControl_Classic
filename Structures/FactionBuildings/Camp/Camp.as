#include "StandardRespawnCommand.as";
#include "Requirements.as";
#include "StoreCommon.as";
#include "FactionBuildingCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.Tag("ignore extractor");

	this.set_TileType("background tile", CMap::tile_wood_back);

	this.addCommandID("sv_store");

	this.Tag("minimap_small");
	this.set_u8("minimap_index", 1);

	this.set_Vec2f("travel button pos", Vec2f(0.5f, 1));

	// Respawning & class changing
	this.Tag("respawn");
	InitClasses(this);

	// Inventory
	//this.Tag("change class store inventory");
	this.inventoryButtonPos = Vec2f(28, -5);

	server_SetFloor(this, CMap::tile_wood);

	this.setInventoryName(name(Translate::Camp));

	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, Translate::Upgrades);
	shop.menu_size = Vec2f(4, 2);
	shop.button_offset = Vec2f(-24, 10);
	shop.button_icon = 15;

	{
		SaleItem s(shop.items, name(Translate::UpgradeCamp), "$icon_upgrade$", "fortress", desc(Translate::UpgradeCamp), ItemType::nothing);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 750);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 300);
		AddRequirement(s.requirements, "coin", "", "Coins", 250);
		s.button_dimensions = Vec2f(2, 2);
	}
	{
		SaleItem s(shop.items, name(Translate::Repair), "$icon_repair$", "repair", desc(Translate::Repair), ItemType::nothing);	
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 50);
		s.button_dimensions = Vec2f(2, 2);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	Shop@ shop;
	if (!this.get("shop", @shop)) return;

	const bool accessible = isInventoryAccessible(this, caller);
	if (accessible)
	{
		caller.CreateGenericButton("$change_class$", Vec2f(-12, -2.5f), this, buildSpawnMenu, getTranslatedString("Change class"));

		CInventory@ inv = caller.getInventory();
		if (inv !is null && inv.getItemsCount() > 0)
		{
			caller.CreateGenericButton(28, Vec2f(14, 5), this, this.getCommandID("sv_store"), getTranslatedString("Store"));
		}
	}
	
	shop.available = accessible;
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	if (item.blob_name == "fortress")
	{
		this.getSprite().getVars().gibbed = true;
		this.getSprite().PlaySound("/Construct.ogg");

		if (isServer())
		{
			CBlob@ newBlob = server_CreateBlob("fortress", this.getTeamNum(), this.getPosition());
			this.MoveInventoryTo(newBlob);
			this.Tag("upgrading");
			this.server_Die();
		}
	}
	else if (item.blob_name == "repair")
	{
		this.getSprite().PlaySound("/ConstructShort.ogg");

		if (isServer())
		{
			const f32 heal = this.getInitialHealth() * 0.05f;
			this.server_SetHealth(Maths::Min(this.getHealth() + heal, this.getInitialHealth()));
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	onRespawnCommand(this, cmd, params);

	if (cmd == this.getCommandID("sv_store") && isServer())
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
	return (forBlob.getTeamNum() == this.getTeamNum() && isOverlapping(this, forBlob));
}

bool isOverlapping(CBlob@ a, CBlob@ b) //engine overlapping sometimes fails
{
	Vec2f a_min, a_max, b_min, b_max;
	a.getShape().getBoundingRect(a_min, a_max);
	b.getShape().getBoundingRect(b_min, b_max);
	return (a_max.x > b_min.x && a_min.x < b_max.x && a_max.y > b_min.y && a_min.y < b_max.y);
}
