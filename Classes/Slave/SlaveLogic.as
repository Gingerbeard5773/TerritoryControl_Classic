#include "Hitters.as";

void onInit(CBlob@ this)
{
	this.Tag("neutral");
	
	//this.set_f32("mining_multiplier", 1.5f);
	
	if (isServer())
	{
		this.server_setTeamNum(250);
		
		CBlob@ ball = server_CreateBlobNoInit("slaveball");
		ball.setPosition(this.getPosition());
		ball.server_setTeamNum(-1);
		ball.set_u16("slave_id", this.getNetworkID());
		ball.Init();
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob !is this;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	switch(customData)
	{
		case Hitters::nothing:
		case Hitters::suddengib:
		case Hitters::suicide:
			damage = 0;
			break;
	}

	return damage;
}

// bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
// {
	// return byBlob.getConfig() != "slave";
// }
