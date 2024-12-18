void onTick(CBlob@ this)
{
	if (!isServer()) return;

	if (getGameTime() % 30 != 0) return;

	CBlob@ inventoryBlob = this.getInventoryBlob();
	if (inventoryBlob is null) return;

	inventoryBlob.server_Heal(0.25f);
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	this.doTickScripts = true;

	inventoryBlob.Tag("bubblegem");
}

void onThisRemoveFromInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (!isServer()) return;

	if (inventoryBlob.getInventory().getCount(this.getName()) == 0)
	{
		inventoryBlob.Untag("bubblegem");
		inventoryBlob.Sync("bubblegem", true);
	}
}
