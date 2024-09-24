
void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.Tag("place norotate");

	this.Tag("ignore extractor");
	this.Tag("builder always hit");
	this.Tag("remote storage");
}


void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || this.isAttached()) return;
	
	if (blob.isAttached() || blob.hasTag("player") || blob.getShape().isStatic()) return;

	if (blob.getOldVelocity().Length() >= 8.0f) return; 
	
	if (blob.canBePutInInventory(this))
	{
		this.server_PutInInventory(blob);
		this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return false;
}
