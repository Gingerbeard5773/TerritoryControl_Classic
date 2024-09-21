// A script by TFlippy

#include "Requirements.as"
#include "ShopCommon.as"
#include "Descriptions.as"
#include "GenericButtonCommon.as"
#include "TeamIconToken.as"

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.Tag("has window");
	this.Tag("builder always hit");
	
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_Vec2f("shop menu size", Vec2f(4, 2));
	this.set_string("shop description", "Builder's Workshop");
	this.set_u8("shop icon", 15);
	
	const u8 team_num = this.getTeamNum();
	
	{
		ShopItem@ s = addShopItem(this, "Lantern", "$lantern$", "lantern", Descriptions::lantern, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Bucket", "$bucket$", "bucket", Descriptions::bucket, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 10);
	}
	{
		ShopItem@ s = addShopItem(this, "Sponge", "$sponge$", "sponge", Descriptions::sponge, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 50);
	}
	{
		ShopItem@ s = addShopItem(this, "Trampoline", getTeamIcon("trampoline", "Trampoline.png", team_num, Vec2f(32, 16), 3), "trampoline", Descriptions::trampoline, false);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
	}
	{
		ShopItem@ s = addShopItem(this, "Crate", "$crate$", "crate", "A wooden crate used for storage.\nBreaks upon impact.", true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_bool("shop available", this.isOverlapping(caller));
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("ConstructShort");
	}
}
