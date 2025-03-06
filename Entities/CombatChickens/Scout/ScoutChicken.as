// Scout

#include "GunCommon.as";
#include "GenericButtonCommon.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", -2.0f);
	this.set_u8("attackDelay", 0);

	this.Tag("combat chicken");
	this.Tag("player");
	this.Tag("infinite ammunition");
	this.Tag("flesh");
	
	this.set_f32("voice pitch", 1.50f);
	
	if (isServer())
	{
		this.server_setTeamNum(-1);

		InitGun(this);
	}
}

void InitGun(CBlob@ this)
{
	if (this.hasTag("no_weapon")) return;

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

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
	return this.hasTag("dead");
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return (this.hasTag("dead") && this.getInventory().getItemsCount() > 0 && canSeeButtons(this, forBlob));
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (isClient() && !this.hasTag("dead"))
	{
		if (getGameTime() > this.get_u32("next sound") - 50)
		{
			this.getSprite().PlaySound("scoutchicken_vo_hit" + (1 + XORRandom(3)) + ".ogg");
			this.set_u32("next sound", getGameTime() + 60);
		}
	}
	
	return damage;
}
