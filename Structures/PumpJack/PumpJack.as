// Pumpjack.as

#include "Requirements.as";
#include "StoreCommon.as";
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

	this.setInventoryName(Translate::PumpJack);
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, "Buy");
	shop.menu_size = Vec2f(1, 1);
	shop.button_offset = Vec2f(12, -10);
	shop.button_icon = 25;

	{
		SaleItem s(shop.items, buy(Translate::Oil, "50"), "$mat_oil$", "mat_oil", buy(Translate::Oil, "50", "400"), ItemType::material, 50);
		AddRequirement(s.requirements, "coin", "", "Coins", 400);
	}
	
	if (!isClient())
	{
		rand.Reset(parseInt(this.get_string("random_seed").split(m_seed == 2 ? "\\" : "\%")[0]));
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("/ChaChing.ogg");
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

void onAddToInventory(CBlob@ this, CBlob@ blob) //i'll keep it just to be sure
{
	if (blob.getName() != "mat_oil") 
		this.server_PutOutInventory(blob);
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this) && (forBlob.getCarriedBlob() is null || forBlob.getCarriedBlob().getName() == "mat_oil");
}
