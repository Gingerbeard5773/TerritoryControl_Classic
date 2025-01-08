// A script by TFlippy

#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	
	this.Tag("ignore extractor");

	this.addCommandID("server_setowner");
	this.addCommandID("client_setowner");
	this.addCommandID("server_store");
	
	SetInventoryName(this);
}

void SetInventoryName(CBlob@ this)
{
	const string owner = this.get_string("Owner");
	const string name = owner.isEmpty() ? Translate::Locker0 : Translate::Locker1.replace("{OWNER}", owner);
	this.setInventoryName(name);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
	if (caller.isOverlapping(this) && this.get_string("Owner").isEmpty())
	{
		caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("server_setowner"), Translate::Claim);
	}
	
	CPlayer@ player = caller.getPlayer();
	if (player is null) return;
	
	if (player.getUsername() == this.get_string("Owner"))
	{
		CInventory@ inv = caller.getInventory();
		if (inv is null) return;

		if (inv.getItemsCount() > 0)
		{
			caller.CreateGenericButton(28, Vec2f(0, 8), this, this.getCommandID("server_store"), getTranslatedString("Store"));
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
		this.server_setTeamNum(player.getTeamNum());
		
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
	else if (cmd == this.getCommandID("server_store") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		CBlob@ caller = player.getBlob();
		if (caller is null) return;

		CBlob@ carried = caller.getCarriedBlob();
		if (carried !is null && carried.hasTag("temp blob"))
		{
			carried.server_Die();
		}

		CInventory@ inv = caller.getInventory();
		if (inv !is null)
		{
			while (inv.getItemsCount() > 0)
			{
				CBlob @item = inv.getItem(0);
				caller.server_PutOutInventory(item);
				this.server_PutInInventory(item);
			}
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

void onDie(CBlob@ this)
{
	const string owner = this.get_string("Owner");
	if (!owner.isEmpty())
	{
		client_AddToChat(Translate::Locker2.replace("{OWNER}", owner));
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	CPlayer@ player = forBlob.getPlayer();
	return player !is null && player.getUsername() == this.get_string("Owner");
}
