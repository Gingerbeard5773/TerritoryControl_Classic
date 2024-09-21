
void TryToAttachVehicle(CBlob@ blob, CBlob@ toBlob = null, const string&in attachment_point_name = "VEHICLE")
{	
	if (blob is null || blob.getAttachments() is null) return;

	AttachmentPoint@ ap = blob.getAttachments().getAttachmentPointByName(attachment_point_name);
	if (ap !is null && !ap.socket && ap.getOccupied() is null)
	{
		CBlob@[] blobsInRadius;
		if (toBlob !is null)
			blobsInRadius.push_back(toBlob);
		else
			getMap().getBlobsInRadius(blob.getPosition(), blob.getRadius() * 1.5f + 64.0f, @blobsInRadius);

		for (uint i = 0; i < blobsInRadius.length; i++)
		{
			CBlob@ b = blobsInRadius[i];
			AttachmentPoint@[] points;

			if (b.getTeamNum() == blob.getTeamNum() && b.getAttachmentPoints(@points))
			{
				for (uint j = 0; j < points.length; j++)
				{
					AttachmentPoint@ att = points[j];
					if (att !is null && att.socket && att.name == attachment_point_name && att.getOccupied() is null)
					{
						b.server_AttachTo(blob, att);
						return;
					}
				}
			}
		}
	}
}
