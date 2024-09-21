// Vehicle Workshop

#include "Requirements.as";
#include "ShopCommon.as";
#include "Descriptions.as";

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	// SHOP
	this.set_Vec2f("shop offset", Vec2f(0, 8));
	this.set_Vec2f("shop menu size", Vec2f(12, 6));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	
	//ShopMadeItem@ onMadeItem = @onShopMadeItem;
	//this.set("onShopMadeItem handle", @onMadeItem);
	
	{
		ShopItem@ s = addShopItem(this, "Catapult", "$catapult$", "catapult", "$catapult$\n\n\n" + Descriptions::catapult, false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
		s.crate_icon = 4;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Ballista", "$ballista$", "ballista", "$ballista$\n\n\n" + Descriptions::ballista, false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.crate_icon = 5;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Steam Tank", "$icon_steamtank$", "steamtank", "$icon_steamtank$\n\n\n" + "An armored land vehicle. Comes with a powerful cannon and a durable ram.", false, true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 10);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.crate_icon = 7;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	
	// {
		// ShopItem@ s = addShopItem(this, "Ballista Ammo", "$mat_bolts$", "mat_bolts", "$mat_bolts$\n\n\n" + descriptions[15], false, false);
		// s.crate_icon = 5;
		// s.customButton = true;
		// s.buttonwidth = 2;
		// s.buttonheight = 2;
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 160);
		// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 80);
		// AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 20);
	// }
	{
		ShopItem@ s = addShopItem(this, "Dinghy", "$dinghy$", "dinghy", "$dinghy$\n\n\n" + Descriptions::dinghy);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
		
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	// {
		// ShopItem@ s = addShopItem(this, "Buoy", "$buoy_icon$", "buoy", "Useful for anchoring.");
		// // AddRequirement(s.requirements, "blob", "mat_hemp", "Hemp", 5);
		// AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 100);
		// AddRequirement(s.requirements, "blob", "mat_gold", "Gold", 100);
		// AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 100);
		// s.spawnNothing = true;
	// }
	{
		ShopItem@ s = addShopItem(this, "Longboat", "$longboat$", "longboat", "$longboat$\n\n\n" + Descriptions::longboat, false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 120);
		s.crate_icon = 1;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "War Boat", "$warboat$", "warboat", "$warboat$\n\n\n" + Descriptions::warboat, false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 500);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_icon = 2;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}


	{
		ShopItem@ s = addShopItem(this, "Machine Gun", "$icon_gatlinggun$", "gatlinggun", "Useful for making holes.", false, true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 4);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
		s.crate_icon = 11;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Mortar", "$icon_mortar$", "mortar", "Mortar combat!", false, true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 6);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
		s.crate_icon = 3;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Bomber", "$icon_bomber$", "bomber", "$icon_bomber$\n\n\n\n\n\n\n\n" + "A large aerial vehicle used for safe transport and bombing the peasants below.", false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.crate_icon = 13;
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 4;
	}
	
	
	{
		ShopItem@ s = addShopItem(this, "Armored Bomber", "$icon_armoredbomber$", "armoredbomber", "$icon_armoredbomber$\n\n\n\n\n\n\n\n" + "A fortified but slow moving balloon with an iron basket and two attachment slots. Resistant against gunfire.", false, true);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 200);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 2);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_icon = 13;
		s.customButton = true;
		s.buttonwidth = 4;
		s.buttonheight = 4;
	}
	
	{
		ShopItem@ s = addShopItem(this, "Howitzer", "$icon_howitzer$", "howitzer", "Mortar's bigger brother.", false, true);
		AddRequirement(s.requirements, "blob", "mat_steelingot", "Steel Ingot", 5);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 75);
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
		s.crate_icon = 12;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
	{
		ShopItem@ s = addShopItem(this, "Rocket Launcher", "$icon_rocketlauncher$", "rocketlauncher", "A rapid-fire rocket launcher especially useful against aerial targets.", false, true);
		AddRequirement(s.requirements, "blob", "mat_ironingot", "Iron Ingot", 2);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 150);
		AddRequirement(s.requirements, "coin", "", "Coins", 150);
		s.crate_icon = 12;
		s.customButton = true;
		s.buttonwidth = 2;
		s.buttonheight = 2;
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", this.isOverlapping(caller));
}

/*void onShopMadeItem(CBitStream@ params)
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
}*/

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("/ChaChing.ogg");
	}
}

void onInit(CSprite@ this)
{
	this.SetZ(50); //foreground

	CBlob@ blob = this.getBlob();
	CSpriteLayer@ planks = this.addSpriteLayer("planks", this.getFilename() , 64, 56, blob.getTeamNum(), blob.getSkinNum());

	if (planks !is null)
	{
		Animation@ anim = planks.addAnimation("default", 0, false);
		anim.AddFrame(1);
		planks.SetOffset(Vec2f(0.0f, 0.0f));
		planks.SetRelativeZ(-100);
	}
}