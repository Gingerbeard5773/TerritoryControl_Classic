//Merchant.as

#include "Requirements.as";
#include "StoreCommon.as";
#include "Descriptions.as";
#include "MakeSeed.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.Tag("change team on fort capture");

	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);

	this.getCurrentScript().tickFrequency = 30 * 3;

	this.setInventoryName(Translate::Merchant);
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, "Buy");
	shop.menu_size = Vec2f(3, 4);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 25;

	{
		SaleItem s(shop.items, buy(name(Translate::GoldIngot), "1"), "$icon_goldingot$", "mat_goldingot", buy(name(Translate::GoldIngot), "1", "100"), ItemType::material, 1);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		SaleItem s(shop.items, buy("Stone", "250"), "$mat_stone$", "mat_stone", buy("Stone", "250", "125"), ItemType::normal, 250);
		AddRequirement(s.requirements, "coin", "", "Coins", 125);
	}
	{
		SaleItem s(shop.items, buy("Wood", "250"), "$mat_wood$", "mat_wood", buy("Wood", "250", "90"), ItemType::material, 250);
		AddRequirement(s.requirements, "coin", "", "Coins", 90);
	}
	{
		SaleItem s(shop.items, sell(name(Translate::GoldIngot), "1"), "$COIN$", "coin", sell(name(Translate::GoldIngot), "1", "100"), ItemType::coin, 100);
		AddRequirement(s.requirements, "blob", "mat_goldingot", name(Translate::GoldIngot), 1);
	}
	{
		SaleItem s(shop.items, sell("Stone", "250"), "$COIN$", "coin", sell("Stone", "250", "100"), ItemType::coin, 100);
		AddRequirement(s.requirements, "blob", "mat_stone", "Stone", 250);
	}
	{
		SaleItem s(shop.items, sell("Wood", "250"), "$COIN$", "coin", sell("Wood", "250", "75"), ItemType::coin, 75);
		AddRequirement(s.requirements, "blob", "mat_wood", "Wood", 250);
	}
	{
		SaleItem s(shop.items, name(Translate::MusicDisc), "$icon_musicdisc$", "musicdisc", desc(Translate::MusicDisc));
		AddRequirement(s.requirements, "coin", "", "Coins", 30);
	}
	{
		SaleItem s(shop.items, sell(Translate::Oil, "50"), "$COIN$", "coin", sell(Translate::Oil, "50", "300"), ItemType::coin, 300);
		AddRequirement(s.requirements, "blob", "mat_oil", Translate::Oil, 50);
	}
	{
		SaleItem s(shop.items, name(Translate::Tree), "$icon_seed$", "seed", desc(Translate::Tree), ItemType::nothing);
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		SaleItem s(shop.items, name(Translate::Cake), "$icon_cake$", "cake", desc(Translate::Cake));
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		SaleItem s(shop.items, name(Translate::Car), "$icon_car$", "car", desc(Translate::Car), ItemType::crate);
		AddRequirement(s.requirements, "coin", "", "Coins", 1000);
	}
	
	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		const string sex = traderRandom.NextRanged(2) == 0 ? "TraderMale.png" : "TraderFemale.png";
		CSpriteLayer@ trader = sprite.addSpriteLayer("trader", sex, 16, 16, 0, 0);
		trader.SetRelativeZ(20);
		Animation@ stop = trader.addAnimation("stop", 1, false);
		stop.AddFrame(0);
		Animation@ walk = trader.addAnimation("walk", 1, false);
		walk.AddFrame(0); walk.AddFrame(1); walk.AddFrame(2); walk.AddFrame(3);
		walk.time = 10;
		walk.loop = true;
		trader.SetOffset(Vec2f(0, 8));
		trader.SetFrame(0);
		trader.SetAnimation(stop);
		trader.SetIgnoreParentFacing(true);
		this.set_bool("trader moving", false);
		this.set_bool("moving left", false);
		this.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
		this.set_u32("next offset", traderRandom.NextRanged(16));
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("ChaChing.ogg");

	if (isServer())
	{
		if (item.blob_name == "seed")
		{
			CBlob@ seed = server_MakeSeed(this.getPosition(), XORRandom(2) == 1 ? "tree_pine" : "tree_bushy");
			if (seed is null) return;
		   
			if (!caller.server_PutInInventory(seed))
			{
				caller.server_Pickup(seed);
			}
		}
		else if (blob !is null && item.blob_name == "mat_stone")
		{
			blob.Tag("no stone gold");
			blob.server_SetQuantity(item.quantity);
		}
	}
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	CBlob@[] blobs;
	getBlobsByTag("player", @blobs);
	const u8 myTeam = this.getTeamNum();
	CRules@ rules = getRules();
	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob.getTeamNum() != myTeam) continue;

		CPlayer@ ply = blob.getPlayer();
		if (ply is null) continue;

		const int addCoins = ply.getCoins() + 1;
		ply.server_setCoins(addCoins);
		
		rules.set_u32("old coin count " + ply.getUsername(), addCoins); //dont update coin hover message
		rules.SyncToPlayer("old coin count " + ply.getUsername(), ply);
	}
}

void onTick(CSprite@ this)
{
	//TODO: empty? show it.
	CBlob@ blob = this.getBlob();
	CSpriteLayer@ trader = this.getSpriteLayer("trader");
	bool trader_moving = blob.get_bool("trader moving");
	bool moving_left = blob.get_bool("moving left");
	u32 move_timer = blob.get_u32("move timer");
	u32 next_offset = blob.get_u32("next offset");
	if (!trader_moving)
	{
		if (move_timer <= getGameTime())
		{
			blob.set_bool("trader moving", true);
			trader.SetAnimation("walk");
			trader.SetFacingLeft(!moving_left);
			Vec2f offset = trader.getOffset();
			offset.x *= -1.0f;
			trader.SetOffset(offset);
		}
	}
	else
	{
		//had to do some weird shit here because offset is based on facing
		Vec2f offset = trader.getOffset();
		if (moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);
		}
		else if (moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", false);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
		}
		else if (!moving_left && offset.x > -next_offset)
		{
			offset.x -= 0.5f;
			trader.SetOffset(offset);
		}
		else if (!moving_left && offset.x <= -next_offset)
		{
			blob.set_bool("trader moving", false);
			blob.set_bool("moving left", true);
			blob.set_u32("move timer", getGameTime() + (traderRandom.NextRanged(5) + 5)*getTicksASecond());
			blob.set_u32("next offset", traderRandom.NextRanged(16));
			trader.SetAnimation("stop");
		}
	}
}
