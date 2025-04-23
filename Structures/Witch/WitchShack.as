// Witchshack.as

#include "Requirements.as";
#include "StoreCommon.as";
#include "MaterialCommon.as";
#include "TC_Translation.as";

Random traderRandom(Time());

void onInit(CBlob@ this)
{
	this.Tag("change team on fort capture");

	this.SetMinimapOutsideBehaviour(CBlob::minimap_none);
	this.SetMinimapVars("GUI/Minimap/MinimapIcons.png", 6, Vec2f(8, 8));
	this.SetMinimapRenderAlways(true);
	
	this.getCurrentScript().tickFrequency = 30 * 8;

	this.setInventoryName(Translate::WitchShack);
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, Translate::WitchShack);
	shop.menu_size = Vec2f(2, 3);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 25;
	
	{
		SaleItem s(shop.items, name(Translate::ProcessMithril)+" (1)", "$icon_mithrilingot$", "mat_mithrilingot", desc(Translate::ProcessMithril), ItemType::material, 1);
		AddRequirement(s.requirements, "blob", "mat_mithril", Translate::MithrilOre, 10);
		AddRequirement(s.requirements, "coin", "", "Coins", 25);
	}
	{
		SaleItem s(shop.items, name(Translate::ProcessMithril)+" (4)", "$icon_mithrilingot$", "mat_mithrilingot", desc(Translate::ProcessMithril), ItemType::material, 4);
		AddRequirement(s.requirements, "blob", "mat_mithril", Translate::MithrilOre, 40);
		AddRequirement(s.requirements, "coin", "", "Coins", 100);
	}
	{
		SaleItem s(shop.items, name(Translate::CardPack), "$card_pack$", "card_pack", desc(Translate::CardPack));
		AddRequirement(s.requirements, "coin", "", "Coins", 50);
	}
	{
		SaleItem s(shop.items, name(Translate::MysteryBox), "$icon_mysterybox$", "mysterybox", desc(Translate::MysteryBox));
		AddRequirement(s.requirements, "coin", "", "Coins", 75);
	}
	{
		SaleItem s(shop.items, name(Translate::BubbleGem), "$bubble_gem$", "bubblegem", desc(Translate::BubbleGem));
		AddRequirement(s.requirements, "coin", "", "Coins", 200);
	}
	{
		SaleItem s(shop.items, name(Translate::Choker), "$choker_gem$", "choker", desc(Translate::Choker));
		AddRequirement(s.requirements, "blob", "mat_methane", Translate::Methane, 50);
		AddRequirement(s.requirements, "blob", "mat_mithrilingot", Translate::MithrilIngot, 2);
	}

	CSprite@ sprite = this.getSprite();
	if (sprite !is null)
	{
		CSpriteLayer@ trader = sprite.addSpriteLayer("trader", "witch", 16, 24, 0, 0);
		trader.SetRelativeZ(20);
		Animation@ stop = trader.addAnimation("stop", 1, false);
		stop.AddFrame(0);
		Animation@ walk = trader.addAnimation("walk", 1, false);
		walk.AddFrame(0); walk.AddFrame(1); walk.AddFrame(2); walk.AddFrame(3);
		walk.time = 10;
		walk.loop = true;
		trader.SetOffset(Vec2f(0, 4));
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
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	const u8 team = this.getTeamNum();
	if (team >= getRules().getTeamsCount()) return;

	CBlob@[] blobs;
	getBlobsByTag("player", @blobs);
	for (uint i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob.getTeamNum() != team || blob.hasTag("dead")) continue;

		blob.server_SetHealth(Maths::Min(blob.getHealth() + 0.125f, blob.getInitialHealth()));
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
