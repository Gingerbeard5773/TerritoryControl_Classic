//for use with DefaultActorHUD.as based HUDs

//Gingerbeard rewrote this script to be more optimized and show items and their quantities better.

Vec2f getActorHUDStartPosition(CBlob@ blob, const u8 bar_width_in_slots)
{
    f32 width = bar_width_in_slots * 32.0f;
    return Vec2f(getScreenWidth() / 2.0f + 160 - width, getScreenHeight() - 40);
}

void DrawInventoryOnHUD(CBlob@ this, Vec2f tl, Vec2f hudPos = Vec2f(0,0))
{	 
	CInventory@ inv = this.getInventory();	 
	if (inv is null) return;
	
	CBlob@[] items;
	string[] names;
	int[] quantities;
	
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		const string name = item.getName();
		const int index = names.find(name);
		if (index == -1)
		{
			items.push_back(item);
			names.push_back(name);
			quantities.push_back(item.getQuantity());
		}
		else
		{
			quantities[index] += item.getQuantity();
		}
	}
	
	for (int i = 0; i < items.length; i++)
	{
		CBlob@ item = items[i];
		const int quantity = quantities[i];

		//vertical belt
		Vec2f itempos = Vec2f(10, 54 + i * 46) + hudPos;
		GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), Vec2f(2, 46 + i * 46) + hudPos);
		GUI::DrawIcon(item.inventoryIconName, item.inventoryIconFrame, item.inventoryFrameDimension, itempos, 1.0f); 

		const f32 ratio = float(quantity) / float(item.maxQuantity);
		SColor col = ratio > 0.4f ? SColor(255, 255, 255, 255) :
		             ratio > 0.2f ? SColor(255, 255, 255, 128) :
		             ratio > 0.1f ? SColor(255, 255, 128, 0) : SColor(255, 255, 0, 0);

		if (quantity != 1)
		{
			const int textwidth = int(("" + quantity).get_length());
			GUI::SetFont("menu");
			GUI::DrawText(""+quantity, itempos + Vec2f(30 - (textwidth * 8), 18), col);
		}
	}
}

void DrawCoinsOnHUD(CBlob@ this, const int coins, Vec2f tl, const int slot)
{
	GUI::DrawIcon("GUI/jitem.png", 14, Vec2f(16, 16), Vec2f(42, 38));
	GUI::SetFont("menu");
	GUI::DrawText(""+coins, Vec2f(72, 44), color_white);
}
