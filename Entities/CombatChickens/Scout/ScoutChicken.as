// Scout brain

#include "BrainCommon.as"
#include "GunCommon.as";
#include "GenericButtonCommon.as";

const int drop_coins = 150;

void onInit(CBrain@ this)
{
	if (isServer())
	{
		InitBrain(this);
		this.server_SetActive(true); // always running
	}
}

void onInit(CBlob@ this)
{
	this.set_f32("gib health", 0.0f);
	this.set_u32("nextAttack", 20);
	this.set_u8("attackDelay", 0);

	this.Tag("combat chicken");
	this.Tag("player");
	this.Tag("infinite ammunition");
	this.Tag("flesh");
	
	this.set_f32("voice pitch", 1.50f);
	
	if (isServer())
	{
		this.server_setTeamNum(-1);

		string gun_config;

		switch(XORRandom(11))
		{
			case 0:
			case 1:
			case 2:
			case 3:
			case 4:
				gun_config = "revolver";
				this.set_u8("attackDelay", 5);
				break;
			case 5:
			case 6:
				gun_config = "rifle";
				this.set_u8("attackDelay", 30);
				break;
			case 7:
			case 8:
				gun_config = "shotgun";
				this.set_u8("attackDelay", 30);
				break;
			case 9:
				gun_config = "bazooka";
				this.set_u8("attackDelay", 30);
				break;
			case 10:
				gun_config = "smg";
				this.set_u8("attackDelay", 3);
				break;
		}

		CBlob@ newgun = server_CreateBlob(gun_config, this.getTeamNum(), this.getPosition());
		this.server_Pickup(newgun);
		
		GunInfo@ gun;
		if (newgun.get("gunInfo", @gun))
		{
			gun.ammo = gun.ammo_max;
			
			for (u8 i = 0; i < 3; i++)
			{
				CBlob@ ammo = server_CreateBlob(gun.ammo_name, this.getTeamNum(), this.getPosition());
				this.server_PutInInventory(ammo);
			}
		}
	}
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (this.hasTag("dead") && this.getInventory().getItemsCount() > 0 && canSeeButtons(this, forBlob));
}

void onTick(CBlob@ this)
{
	if (this.getHealth() < 3.0 && !this.hasTag("dead"))
	{
		this.Tag("dead");
		this.getSprite().PlaySound("Wilhelm.ogg", 1.8f, 1.8f);

		this.getShape().getVars().isladder = false;
		this.getShape().getVars().onladder = false;
		this.getShape().checkCollisionsAgain = true;
		this.getShape().SetGravityScale(1.0f);

		if (isServer())
		{
			server_DropCoins(this.getPosition(), drop_coins);

			this.server_DetachAll();
			
			if (XORRandom(100) < 5) server_CreateBlob("phone", -1, this.getPosition());
		}
		
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}

	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") && XORRandom(100) < 5)
		{
			this.set_u32("next sound", getGameTime() + 100);
		}
	}
}

void onTick(CBrain@ this)
{
	if (!isServer()) return;

	CBlob@ blob = this.getBlob();
	if (blob.getPlayer() !is null)
	{
		this.getCurrentScript().tickFrequency = -1; //turn off
		return;
	}
	
	SearchTarget(this, false, true);
	CBlob@ target = this.getTarget();
	
	if (target !is null)
	{
		this.getCurrentScript().tickFrequency = 1;
		
		const f32 distance = (target.getPosition() - blob.getPosition()).getLength();
		f32 visibleDistance;
		const bool visibleTarget = isVisible(blob, target, visibleDistance);

		if (target.hasTag("dead") || distance > 400.0f) 
		{
			if (target.hasTag("dead"))
			{
				blob.getSprite().PlaySound("scoutchicken_vo_victory.ogg");
			}
			blob.setKeyPressed(key_action1, false);
			this.SetTarget(null);
			return;
		}

		if (visibleTarget && visibleDistance < 25.0f) 
		{
			DefaultRetreatBlob(blob, target);
		}	
		else if (target.isOnGround())
		{
			DefaultChaseBlob(blob, target);
		}

		if (visibleTarget && distance < 350.0f && blob.getCarriedBlob() !is null)
		{
			Vec2f randomness = Vec2f((100 - XORRandom(200)) * 0.1f, (100 - XORRandom(200)) * 0.1f);
			blob.setAimPos(target.getPosition() + randomness);

			if (blob.get_u32("nextAttack") < getGameTime())
			{
				blob.setKeyPressed(key_action1, true);
				blob.set_u32("nextAttack", getGameTime() + blob.get_u8("attackDelay"));
			}
		}
		
		LoseTarget(this, target);
	}
	else
	{
		this.getCurrentScript().tickFrequency = 30;
		blob.setKeyPressed(key_action1, false);
		blob.set_u32("nextAttack", getGameTime() + 50);
		RandomTurn(blob);		
	}

	FloatInWater(blob); 
} 

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isClient())
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("scoutchicken_vo_hit" + (1 + XORRandom(3)) + ".ogg");
			this.set_u32("next sound", getGameTime() + 60);
		}
	}
	
	if (isServer())
	{
		if (hitterBlob !is null && hitterBlob.getTeamNum() != this.getTeamNum())
		{
			CPlayer@ hitterPlayer = hitterBlob.getDamageOwnerPlayer();
			if (hitterPlayer !is null)
			{
				CBlob@ hitterPlayerBlob = hitterPlayer.getBlob();
				if (hitterPlayerBlob !is null)
				{
					this.getBrain().SetTarget(hitterPlayerBlob);
				}
			}
			else if (hitterBlob.hasTag("flesh"))
			{
				this.getBrain().SetTarget(hitterBlob);
			}
		}
	}
	
	return damage;
}
