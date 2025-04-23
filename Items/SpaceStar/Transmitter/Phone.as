// Phone.as

#include "Requirements.as";
#include "StoreCommon.as";
#include "MakeCrate.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(Translate::Phone);

	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, Translate::Phone);
	shop.menu_size = Vec2f(2, 1);
	shop.button_offset = Vec2f_zero;
	shop.button_icon = 11;

	{
		SaleItem s(shop.items, name(Translate::ChickenSquad), "$ss_raid$", "raid", desc(Translate::ChickenSquad), ItemType::nothing);
		AddRequirement(s.requirements, "coin", "", "Coins", 1249);
	}
	{
		SaleItem s(shop.items, name(Translate::Minefield), "$ss_minefield$", "minefield", desc(Translate::Minefield), ItemType::nothing);
		AddRequirement(s.requirements, "coin", "", "Coins", 799);
	}
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound(XORRandom(100) > 50 ? "/ss_order.ogg" : "/ss_shipment.ogg");
	
	if (isServer())
	{
		if (item.blob_name == "raid")
		{
			for (int i = 0; i < 4; i++)
			{
				CBlob@ blob = server_MakeCrateOnParachute("scoutchicken", "SpaceStar Ordering Assault Squad", 0, -1, Vec2f(caller.getPosition().x + (64 - XORRandom(128)), XORRandom(32)));
				blob.Tag("unpack on land");
				blob.Tag("destroy on touch");
			}
		}
		else if (item.blob_name == "minefield")
		{
			for (int i = 0; i < 10; i++)
			{
				CBlob@ blob = server_MakeCrateOnParachute("mine", "SpaceStar Ordering Mines", 0, -1, Vec2f(caller.getPosition().x + (256 - XORRandom(512)), XORRandom(64)));
				blob.Tag("unpack on land");
				blob.Tag("destroy on touch");
			}
		}
	}
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint @ap)
{
	this.getSprite().PlaySound("/ss_hello.ogg");
}
