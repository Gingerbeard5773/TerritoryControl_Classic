// A script by TFlippy

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	
	this.server_setTeamNum(-1);
	
	this.inventoryButtonPos = Vec2f(0, 0);
	
	this.Tag("ignore extractor");
	
	this.set_string("Owner", "");
	this.addCommandID("sv_setowner");
	this.addCommandID("sv_store");
}

void onTick(CBlob@ this)
{
	this.setInventoryName((this.get_string("Owner") == "" ? "Nobody" : this.get_string("Owner")) + "'s Personal Locker");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
	if (caller.isOverlapping(this) && this.get_string("Owner") == "")
	{
		CButton@ buttonOwner = caller.CreateGenericButton(9, Vec2f(0, 0), this, this.getCommandID("sv_setowner"), "Claim");
	}
	
	CPlayer@ player = caller.getPlayer();
	if (player is null) return;
	
	if (player.getUsername() == this.get_string("Owner"))
	{
		CInventory@ inv = caller.getInventory();
		if (inv is null) return;

		if (inv.getItemsCount() > 0)
		{
			CButton@ buttonOwner = caller.CreateGenericButton(28, Vec2f(0, 8), this, this.getCommandID("sv_store"), "Store");
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sv_setowner") && isServer())
	{
		if (this.get_string("Owner") != "") return;
	
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		this.set_string("Owner", player.getUsername());
		this.server_setTeamNum(player.getTeamNum());
		this.Sync("Owner", true);

		// print("Set owner to " + this.get_string("Owner") + "; Team: " + this.getTeamNum());
	}
	else if (cmd == this.getCommandID("sv_store") && isServer())
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
	return damage * (hitterBlob.getPlayer() is null ? 1.0f : hitterBlob.getPlayer().getUsername() == this.get_string("Owner") ? 4.0f : 1.0f);
}

void onDie(CBlob@ this)
{
	if (this.get_string("Owner") != "") client_AddToChat("" + this.get_string("Owner") + "'s Personal Safe has been destroyed!");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getPlayer().getUsername() == this.get_string("Owner");
}
