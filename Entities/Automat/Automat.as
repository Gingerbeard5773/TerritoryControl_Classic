// Automat

#include "BrainCommon.as";
#include "Hitters.as";
#include "HittersTC.as";

void onInit(CBrain@ this)
{
	if (isServer())
	{
		InitBrain(this);
		this.server_SetActive(true);
	}
}

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.addCommandID("sv_automat_give");
	this.inventoryButtonPos = Vec2f(0, 16);
	
	this.getCurrentScript().tickFrequency = 30;
	this.getCurrentScript().runFlags |= Script::tick_not_ininventory;
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return byBlob.getTeamNum() == this.getTeamNum() && !this.hasAttached();
}

void onTick(CBlob@ this)
{
	if (!isServer()) return;

	CBrain@ brain = this.getBrain();
	SearchTarget(brain, false, true);

	CBlob@ target = brain.getTarget();
	if (target !is null)
	{			
		const f32 distance = (target.getPosition() - this.getPosition()).Length();
		f32 visibleDistance;
		const bool visibleTarget = isVisible(this, target, visibleDistance);
		if (visibleTarget && distance < 230.0f && !target.hasTag("dead") && target.getTeamNum() != this.getTeamNum())
		{
			if (this.getCarriedBlob() !is null)
			{					
				// Vec2f randomness = Vec2f((100 - XORRandom(200)) * 0.1f, (100 - XORRandom(200)) * 0.1f);
				// this.setAimPos(target.getPosition() + randomness);
				this.setAimPos(target.getPosition());
				this.setKeyPressed(key_action1, true);
			}
		
			this.getCurrentScript().tickFrequency = 1;
		}
		else
		{
			brain.SetTarget(null);
		}
	}
	else
	{
		this.getCurrentScript().tickFrequency = 30;
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return forBlob.getTeamNum() == this.getTeamNum();
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller is null) return;
	if (caller.getTeamNum() != this.getTeamNum()) return;

	if ((caller.getPosition() - this.getPosition()).Length() < 24.0f)
	{
		CButton@ button = caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("sv_automat_give"), "Attach Item");
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sv_automat_give") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		CBlob@ caller = player.getBlob();
		if (caller !is null)
		{
			CBlob@ carried_me = this.getCarriedBlob();
			CBlob@ carried_caller = caller.getCarriedBlob();
			if (carried_caller !is null)
			{
				this.server_Pickup(carried_caller);
			}
			else if (carried_me !is null)
			{
				carried_me.server_DetachFrom(this);
			}
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isServer())
	{
		if (hitterBlob !is null && hitterBlob.getTeamNum() != this.getTeamNum())
		{
			this.getBrain().SetTarget(hitterBlob);
		}
	}
	
	switch(customData)
	{
		case HittersTC::bullet:
			damage *= 0.1f;
			break;
		case Hitters::bomb:
		case Hitters::explosion:
		case Hitters::keg:
		case Hitters::mine:
			damage *= 0.2f;
			break;
	}

	return damage;
}
