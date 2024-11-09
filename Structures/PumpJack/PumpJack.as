// Pumpjack.as

#include "Requirements.as";
#include "ShopCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.Tag("change team on fort capture");
	
	this.set_Vec2f("nobuild extend", Vec2f(0.0f, 0.0f));

	this.inventoryButtonPos = Vec2f(12, 8);
	this.getCurrentScript().tickFrequency = 30 * 2; //30 oil per minute

	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png",6,Vec2f(8,8));
	this.SetMinimapRenderAlways(true);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	//SHOP
	this.set_Vec2f("shop offset", Vec2f(12, -10));
	this.set_Vec2f("shop menu size", Vec2f(1, 1));
	this.set_string("shop description", "Buy");
	this.set_u8("shop icon", 25);
	{
		ShopItem@ s = addShopItem(this, buy(Translate::Oil, "50"), "$mat_oil$", "mat_oil-50", buy(Translate::Oil, "50", "400"));
		AddRequirement(s.requirements, "coin", "", "Coins", 400);
		s.spawnNothing = true;
	}
	
	if (!isClient())
	{
		rand.Reset(parseInt(this.get_string("random_seed").split(m_seed == 2 ? "\\" : "\%")[0]));
	}
}

Random rand(1000);

void onInit(CSprite@ this)
{
	CSpriteLayer@ head = this.addSpriteLayer("head", this.getFilename(), 80, 48);
	if (head !is null)
	{
		head.addAnimation("default", 0, true);
		head.SetRelativeZ(-1.0f);
		head.SetOffset(Vec2f(-12, -18));
	}

	this.SetEmitSound("Pumpjack_Ambient.ogg");
	this.SetEmitSoundVolume(0.5f);
	this.SetEmitSoundPaused(false);
}

void onTick(CSprite@ this)
{
	CSpriteLayer@ head = this.getSpriteLayer("head");
	head.ResetTransform();
	head.RotateBy(Maths::Sin((getGameTime() * 0.075f) % 180) * 20.0f, Vec2f_zero);
}

void onTick(CBlob@ this)
{
	if (isServer()) 
	{
		CBlob@ storage = FindStorage(this.getTeamNum());
		if (storage !is null)
		{
			Material::createFor(storage, "mat_oil", XORRandom(3));
		}
		else if (this.getInventory().getCount("mat_oil") < 450)
		{
			Material::createFor(this, "mat_oil", XORRandom(3));
		}
	}
}

CBlob@ FindStorage(u8 team)
{
	if (team >= getRules().getTeamsCount()) return null;
	
	CBlob@[] blobs;
	getBlobsByName("oiltank", @blobs);
	
	CBlob@[] validBlobs;
	
	for (u32 i = 0; i < blobs.length; i++)
	{
		CBlob@ oiltank = blobs[i];
		if (oiltank.getTeamNum() == team && oiltank.getInventory().getCount("mat_oil") < 200)
		{
			validBlobs.push_back(blobs[i]);
		}
	}
	
	if (validBlobs.length == 0) return null;

	return validBlobs[XORRandom(validBlobs.length)];
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	this.set_bool("shop available", caller.getDistanceTo(this) < this.getRadius());
}

void onAddToInventory(CBlob@ this, CBlob@ blob) //i'll keep it just to be sure
{
	if (blob.getName() != "mat_oil") 
		this.server_PutOutInventory(blob);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this) && (forBlob.getCarriedBlob() is null || forBlob.getCarriedBlob().getName() == "mat_oil");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("ChaChing.ogg");
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
