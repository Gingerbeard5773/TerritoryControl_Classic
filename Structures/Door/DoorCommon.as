//common functionality for door-like objects

#include "TeamsCommon.as";

bool canOpenDoor(CBlob@ this, CBlob@ blob)
{
	const u8 team = this.getTeamNum();

	u8 blobteam = blob.getTeamNum();
	const u8 teamsCount = getRules().getTeamsCount();
	if (team < teamsCount)
	{
		TeamData@ teamdata = getTeamData(team);
		if (teamdata !is null && !teamdata.lockdown && blobteam >= teamsCount)
		{
			blobteam = team;
		}
	}

	if ((blob.getShape().getConsts().collidable) && //solid              // vvv lets see
	        (blob.getRadius() > 5.0f) && //large
	        (team == 255 || team == blobteam) &&
	        (blob.hasTag("player") || blob.hasTag("vehicle"))) //tags that can open doors
	{
		Vec2f doorpos = this.getPosition();
		Vec2f blobpos = blob.getPosition();
	
		if (blob.hasTag("vehicle"))
		{
			if (!blob.hasTag("aerial") && doorpos.y > blobpos.y + blob.getHeight()/2 + 2) return false;

			AttachmentPoint@[] aps;
			if (blob.getAttachmentPoints(@aps))
			{
				for (u8 i = 0; i < aps.length; i++)
				{
					if (canOpenDoorVehicle(this, blob, aps[i]))
						return true;
				}
			}
			
			return false;
		}
		
		if (blob.isKeyPressed(key_left)  && blobpos.x > doorpos.x && Maths::Abs(blobpos.y - doorpos.y) < 11) return true;
		if (blob.isKeyPressed(key_right) && blobpos.x < doorpos.x && Maths::Abs(blobpos.y - doorpos.y) < 11) return true;
		if (blob.isKeyPressed(key_up)    && blobpos.y > doorpos.y && Maths::Abs(blobpos.x - doorpos.x) < 11) return true;
		if (blob.isKeyPressed(key_down)  && blobpos.y < doorpos.y && Maths::Abs(blobpos.x - doorpos.x) < 11) return true;
	}
	
	return false;
}

bool canOpenDoorVehicle(CBlob@ this, CBlob@ blob, AttachmentPoint@ ap)
{
	if (ap.name == "ROWER" || ap.name == "DRIVER" || ap.name == "SAIL" || ap.name == "FLYER")
	{
		if (ap.name == "FLYER")
		{
			if (ap.isKeyPressed(key_action1))  return true;
			if (ap.isKeyPressed(key_action2))  return true;
			if (ap.isKeyPressed(key_left))     return true;
			if (ap.isKeyPressed(key_right))    return true;
		}
		else
		{
			if (ap.isKeyPressed(key_left))  return true;
			if (ap.isKeyPressed(key_right)) return true;
		}
	}
	return false;
}

bool isOpen(CBlob@ this) // used by SwingDoor, Bridge, TrapBlock
{
	return !this.getShape().getConsts().collidable;
}
