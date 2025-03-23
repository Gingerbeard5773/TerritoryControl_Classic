// Gingerbeard @ March 17th, 2025

enum SquadTask
{
	IDLE = 0,
	PATROL,
	ATTACK,
	RETREAT,
	DEFEND
}

class Squad
{
	u16[] member_netids;       // Network ids of member blobs
	u16 target_netid;          // Network id of the targeted blob (e.g fortress)
	u8 task;                   // Selected task for the squad to carry out
	Vec2f destination;         // Destination where the bots will attempt to go to
	f32 destination_threshold; // Threshold where bots can consider themselves 'arrived' to the destination
	
	Squad()
	{
		target_netid = 0;
		task = SquadTask::IDLE;
		destination = Vec2f_zero;
		destination_threshold = 32.0f;
	}
	
	CBlob@[] getBlobs()
	{
		CBlob@[] blobs;
		for (int i = 0; i < member_netids.length; i++)
		{
			CBlob@ blob = getBlobByNetworkID(member_netids[i]);
			if (blob is null || blob.hasTag("dead")) continue;

			blobs.push_back(blob);
		}
		return blobs;
	}
	
	CBlob@ getTarget()
	{
		return getBlobByNetworkID(target_netid);
	}
}
