//setup remote access for storages

const u32 remote_access_range = 250.0f;

void server_SetStorageRemoteAccess(CBlob@ this)
{
	if (!isServer()) return;

	this.set_bool("remote access", false);
	CBlob@[] blobs;
	getMap().getBlobsInRadius(this.getPosition(), remote_access_range, @blobs);
	
	const u8 team = this.getTeamNum();
	for (u16 i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob.hasTag("faction_base") && !blob.hasTag("dead") && team == blob.getTeamNum())
		{
			this.set_bool("remote access", true);
			break;
		}
	}
	this.Sync("remote access", true);
}
