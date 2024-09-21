// A script by TFlippy & Pirate-Rob

#include "Requirements.as";
#include "ShopCommon.as";

void onInit(CBlob@ this)
{
	this.getSprite().SetAnimation("default");

	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 8.0f));
	this.Tag("oil_deposit");

	this.SetMinimapOutsideBehaviour(CBlob::minimap_snap);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	AddIconToken("$icon_upgrade$", "InteractionIcons.png", Vec2f(32, 32), 21);
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 2));
	this.set_string("shop description", "");
	this.set_u8("shop icon",15);

	{
		ShopItem@ s = addShopItem(this, "Build a Pumpjack", "$icon_upgrade$", "pumpjack", "Build a Pumpjack.");
		AddRequirement(s.requirements,"blob","mat_stone", "Stone", 100);
		AddRequirement(s.requirements,"blob","mat_wood", "Wood", 350);
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
		s.spawnNothing = true;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("/Construct.ogg");
		this.getSprite().getVars().gibbed = true;
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
	
	if (name == "pumpjack")
	{
		this.server_Die();
		server_CreateBlob("pumpjack", caller.getTeamNum(), this.getPosition());
	}
}
