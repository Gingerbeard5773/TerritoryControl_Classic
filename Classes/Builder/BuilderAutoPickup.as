#define SERVER_ONLY

//#include "CratePickupCommon.as"

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 12;
	this.getCurrentScript().removeIfTag = "dead";
}

const string[] pickup_list = 
{
	"mat_wood",
	"mat_stone",
	"mat_gold",
	"mat_iron",
	"mat_coal",
	"mat_copper",
	"mat_gold",
	"mat_ironingot",
	"mat_steelingot",
	"mat_copperingot",
	"mat_goldingot",
	"mat_mithrilingot",
	"mat_sulphur",
	"mat_dirt",
	"mat_plasteel"
};

void Take(CBlob@ this, CBlob@ blob)
{
	if (!isPickupBlob(blob)) return;
	
	CPlayer@ ownerPlayer = blob.getDamageOwnerPlayer();
	const bool isOwner = ownerPlayer is null || ownerPlayer is this.getPlayer();

	if (getGameTime() < blob.get_u32("autopick time") && isOwner) return;

	if (this.server_PutInInventory(blob)) return;
}

bool isPickupBlob(CBlob@ blob)
{
	return pickup_list.find(blob.getName()) != -1;
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null || blob.getShape().vellen > 1.0f)
	{
		return;
	}

	Take(this, blob);
}

void onTick(CBlob@ this)
{
	CBlob@[] overlapping;
	if (!this.getOverlapping(@overlapping)) return;

	for (uint i = 0; i < overlapping.length; i++)
	{
		CBlob@ blob = overlapping[i];
		if (blob.getShape().vellen > 1.0f) continue;

		Take(this, blob);
	}
}

// make ignore collision time a lot longer for auto-pickup stuff
void IgnoreCollisionLonger(CBlob@ this, CBlob@ blob)
{
	if (this.hasTag("dead")) return;

	if (isPickupBlob(blob))
	{
		blob.set_u32("autopick time", getGameTime() +  getTicksASecond() * 7);
		blob.SetDamageOwnerPlayer(this.getPlayer());
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	IgnoreCollisionLonger(this, detached);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	IgnoreCollisionLonger(this, blob);
}
