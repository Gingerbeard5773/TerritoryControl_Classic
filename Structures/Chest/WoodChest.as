// A script by TFlippy

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");
	
	this.addCommandID("sv_store");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;

	CInventory@ inv = caller.getInventory();
	if (inv is null) return;

	if (inv.getItemsCount() > 0)
	{
		CButton@ buttonOwner = caller.CreateGenericButton(28, Vec2f(0, 8), this, this.getCommandID("sv_store"), "Store");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("sv_store") && isServer())
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

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.isOverlapping(this);
}
