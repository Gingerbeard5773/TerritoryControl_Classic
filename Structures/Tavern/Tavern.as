// A script by TFlippy

#include "Requirements.as"
#include "StoreCommon.as"
#include "MaterialCommon.as"
#include "TC_Translation.as"

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	
	this.set_string("required class", "peasant");
	this.set_string("required tag", "neutral");
	this.set_Vec2f("class offset", Vec2f(-3, -6));

	this.addCommandID("server_setowner");
	this.addCommandID("client_setowner");
	this.addCommandID("server_setspawn");

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Tavern_Ambient.ogg");
	sprite.SetEmitSoundPaused(false);
	sprite.SetEmitSoundVolume(0.60f);
	sprite.SetEmitSoundSpeed(0.90f);
	
	addOnShopMadeItem(this, @onShopMadeItem);

	Shop shop(this, Translate::FunTavern);
	shop.menu_size = Vec2f(3, 2);
	shop.button_offset = Vec2f(-15, 6);
	shop.button_icon = 25;
	
	{
		SaleItem s(shop.items, name(Translate::Beer), "$beer$", "beer", desc(Translate::Beer));
		AddRequirement(s.requirements, "coin", "", "Coins", 29);
	}
	{
		SaleItem s(shop.items, name(Translate::Vodka), "$vodka$", "vodka", desc(Translate::Vodka));
		AddRequirement(s.requirements, "coin", "", "Coins", 91);
	}
	{
		SaleItem s(shop.items, name(Translate::RatBurger), "$ratburger$", "ratburger", Translate::TavernBurger);
		AddRequirement(s.requirements, "coin", "", "Coins", 31);
	}
	{
		SaleItem s(shop.items, name(Translate::RatFood), "$ratfood$", "ratfood", Translate::TavernRat);
		AddRequirement(s.requirements, "coin", "", "Coins", 17);
	}
	{
		SaleItem s(shop.items, name(Translate::BanditMusic), "$musicdisc$", "musicdisc", desc(Translate::BanditMusic), ItemType::nothing);
		AddRequirement(s.requirements, "coin", "", "Coins", 117);
	}
	
	this.SetLight(true);
	this.SetLightRadius(72.0f);
	this.SetLightColor(SColor(255, 255, 150, 50));
	
	SetInventoryName(this);
}

void onShopMadeItem(CBlob@ this, CBlob@ caller, CBlob@ blob, SaleItem@ item)
{
	this.getSprite().PlaySound("MigrantHmm");
	this.getSprite().PlaySound("/ChaChing.ogg");
	
	if (isServer() && item.blob_name == "musicdisc")
	{
		CBlob@ disc = server_CreateBlobNoInit("musicdisc");
		if (disc is null) return;
		disc.setPosition(this.getPosition());
		disc.set_u8("trackID", 18);
		disc.Init();
	   
		if (!caller.server_PutInInventory(disc))
		{
			caller.server_Pickup(disc);
		}
	}
}

void SetInventoryName(CBlob@ this)
{
	const string owner = this.get_string("Owner");
	const string name = owner.isEmpty() ? Translate::ShoddyTavern0 : Translate::ShoddyTavern1.replace("{OWNER}", owner);
	this.set_string("shop description", name);
	this.setInventoryName(name);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.isOverlapping(this) && this.get_string("Owner").isEmpty())
	{	
		caller.CreateGenericButton(11, Vec2f(2, 3), this, this.getCommandID("server_setowner"), Translate::Claim);
	}
	else if (caller.getTeamNum() >= getRules().getTeamsCount())
	{
		CBitStream stream;
		CRules@ rules = getRules();
		if (!rules.exists("tavern_netid") || rules.get_netid("tavern_netid") != this.getNetworkID())
		{
			stream.write_netid(this.getNetworkID());
			caller.CreateGenericButton(29, Vec2f(2, 3), this, this.getCommandID("server_setspawn"), Translate::SetTavern, stream);
		}
		else
		{
			stream.write_netid(0);
			caller.CreateGenericButton(9, Vec2f(2, 3), this, this.getCommandID("server_setspawn"), Translate::UnsetTavern, stream);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("server_setowner") && isServer())
	{
		if (!this.get_string("Owner").isEmpty()) return;

		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		this.set_string("Owner", player.getUsername());
		
		CBitStream stream;
		stream.write_u16(player.getNetworkID());
		this.SendCommand(this.getCommandID("client_setowner"), stream);
	}
	else if (cmd == this.getCommandID("client_setowner") && isClient())
	{
		CPlayer@ player = getPlayerByNetworkId(params.read_u16());
		if (player is null) return;
		
		this.set_string("Owner", player.getUsername());
		SetInventoryName(this);
	}
	else if (cmd == this.getCommandID("server_setspawn") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		const u16 netid = params.read_netid();

		player.set_netid("tavern_netid", netid);

		CRules@ rules = getRules();
		rules.set_netid("tavern_netid", netid);
		rules.SyncToPlayer("tavern_netid", player);
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player = hitterBlob.getPlayer();
	if (player !is null)
	{
		damage *= (player.getUsername() == this.get_string("Owner") ? 4.0f : 1.0f);
	}

	return damage;
}
