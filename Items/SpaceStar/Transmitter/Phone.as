// Phone.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "MakeCrate.as";

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 1;
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	this.set_Vec2f("shop offset", Vec2f(0, 0));
	this.set_Vec2f("shop menu size", Vec2f(2, 1));
	this.set_string("shop description", "SpaceStar Ordering!");
	this.set_u8("shop icon", 11);

	{
		ShopItem@ s = addShopItem(this, "Combat Chicken Assault Squad!", "$ss_raid$", "raid", "Get your own soldier... TODAY!");
		AddRequirement(s.requirements, "coin", "", "Coins", 1249);
		
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, "Portable Minefield!", "$ss_minefield$", "minefield", "A brave flock of landmines! No more trespassers!");
		AddRequirement(s.requirements, "coin", "", "Coins", 799);
		
		s.spawnNothing = true;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound(XORRandom(100) > 50 ? "/ss_order.ogg" : "/ss_shipment.ogg");
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
	if (spl.length > 1)
	{
		if (spl[1] == "parachute")
		{
			CBlob@ blob = server_MakeCrateOnParachute(spl[0], "SpaceStar Ordering Goods", 0, -1, Vec2f(caller.getPosition().x, 0));
			blob.Tag("unpack on land");
		}
	}
	else
	{
		if (spl[0] == "raid")
		{
			for (int i = 0; i < 4; i++)
			{
				CBlob@ blob = server_MakeCrateOnParachute("scoutchicken", "SpaceStar Ordering Assault Squad", 0, -1, Vec2f(caller.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
				blob.Tag("unpack on land");
				blob.Tag("destroy on touch");
			}
		}
		else if (spl[0] == "minefield")
		{
			for (int i = 0; i < 10; i++)
			{
				CBlob@ blob = server_MakeCrateOnParachute("mine", "SpaceStar Ordering Mines", 0, -1, Vec2f(caller.getPosition().x + (256 - XORRandom(512)), XORRandom(64)));
				blob.Tag("unpack on land");
				blob.Tag("destroy on touch");
			}
		}
		else
		{
			CBlob@ blob = server_CreateBlob(spl[0], -1, Vec2f(caller.getPosition().x, 0));
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.getSprite().PlaySound("/ss_hello.ogg");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_Vec2f("shop offset", Vec2f(0,0));
	this.set_bool("shop available", true);
}
