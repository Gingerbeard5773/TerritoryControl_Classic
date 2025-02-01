// A script by TFlippy

#include "Requirements.as"
#include "ShopCommon.as"
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
	
	this.set_Vec2f("shop offset", Vec2f(-15, 6));
	this.set_Vec2f("shop menu size", Vec2f(3, 2));
	this.set_string("shop description", "Fun tavern!");
	this.set_u8("shop icon", 25);
	
	ShopMadeItem@ onMadeItem = @onShopMadeItem;
	this.set("onShopMadeItem handle", @onMadeItem);
	
	{
		ShopItem@ s = addShopItem(this, name(Translate::Beer), "$beer$", "beer", desc(Translate::Beer), false);
		AddRequirement(s.requirements, "coin", "", "Coins", 29);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::Vodka), "$vodka$", "vodka", desc(Translate::Vodka));
		AddRequirement(s.requirements, "coin", "", "Coins", 91);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::RatBurger), "$ratburger$", "ratburger", Translate::TavernBurger);
		AddRequirement(s.requirements, "coin", "", "Coins", 31);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::RatFood), "$ratfood$", "ratfood", Translate::TavernRat);
		AddRequirement(s.requirements, "coin", "", "Coins", 17);
		s.spawnNothing = true;
	}
	{
		ShopItem@ s = addShopItem(this, name(Translate::BanditMusic), "$musicdisc$", "musicdisc", desc(Translate::BanditMusic));
		AddRequirement(s.requirements, "coin", "", "Coins", 117);
		s.spawnNothing = true;
	}
	
	this.SetLight(true);
	this.SetLightRadius(72.0f);
	this.SetLightColor(SColor(255, 255, 150, 50));
	
	SetInventoryName(this);
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
	if (cmd == this.getCommandID("shop made item client") && isClient())
	{
		this.getSprite().PlaySound("MigrantHmm");
		this.getSprite().PlaySound("ChaChing");
	}
	else if (cmd == this.getCommandID("server_setowner") && isServer())
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
	else if (spl[0] == "musicdisc")
	{
		CBlob@ disc = server_CreateBlobNoInit("musicdisc");
		disc.setPosition(this.getPosition());
		disc.set_u8("trackID", 18);
		disc.Init();
		if (disc is null) return;
	   
		if (!disc.canBePutInInventory(caller))
		{
			caller.server_Pickup(disc);
		}
		else if (caller.getInventory() !is null && !caller.getInventory().isFull())
		{
			caller.server_PutInInventory(disc);
		}
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

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player = hitterBlob.getPlayer();
	if (player !is null)
	{
		damage *= (player.getUsername() == this.get_string("Owner") ? 4.0f : 1.0f);
	}

	return damage;
}
