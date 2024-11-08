void onInit(CBlob@ this)
{
	this.Tag("furniture");

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap !is null)
	{
		ap.SetKeysToTake(key_up);
	}
}

void onTick(CBlob@ this)
{
	if (!isServer() || !this.hasAttached()) return;

	AttachmentPoint@ ap = this.getAttachments().getAttachmentPointByName("PILOT");
	if (ap is null) return;

	if (ap.isKeyJustPressed(key_up))
	{
		CBlob@ pilot = ap.getOccupied();
		if (pilot !is null)  pilot.server_DetachFrom(this);
	}
}

// Commented out just in case someone would want to have a jewish wedding in TC
/*bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return !this.hasAttached();
}*/

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
    return blob.getShape().isStatic() || blob.hasTag("furniture");
}
