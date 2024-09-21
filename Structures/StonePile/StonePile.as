// A script by TFlippy & Pirate-Rob

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);
	
	this.Tag("builder always hit");
	this.Tag("change team on fort capture");
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	UpdateFrame(this);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	UpdateFrame(this);
}

void UpdateFrame(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	if (sprite is null) return;
	
	Animation@ animation = sprite.getAnimation("default");
	if (animation is null) return;
	
	CInventory@ inv = this.getInventory();
	if (inv is null) return;
	
	Vec2f slots = inv.getInventorySlots();
	const u16 inventory_size = slots.x * slots.y;
	
	sprite.animation.frame = u8((sprite.animation.getFramesCount() - 1) * (f32(inv.getItemsCount()) / f32(inventory_size)));
}
