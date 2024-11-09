const u8 food_max = 20;

#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::ScrubChowXL));
	this.getShape().SetRotationsAllowed(false);
	this.addCommandID("server eat");
	this.addCommandID("client eat");
	
	this.set_u8("food_amount", food_max);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getHealth() < caller.getInitialHealth())
	{
		CButton@ button = caller.CreateGenericButton(22, Vec2f(0, 0), this, this.getCommandID("server eat"), "Eat (" + this.get_u8("food_amount") + "/" + food_max + ")");
		button.enableRadius = 32.0f;
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server eat") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		CBlob@ caller = player.getBlob();
		if (caller is null) return;

		caller.server_Heal(2.0f);
		
		this.SendCommand(this.getCommandID("client eat"));
		
		if (this.get_u8("food_amount") <= 1)
		{
			this.server_Die();
		}
		else
		{
			this.set_u8("food_amount", this.get_u8("food_amount") - 1);
			this.Sync("food_amount", true);
		}
	}
	else if (cmd == this.getCommandID("client eat") && isClient())
	{
		this.getSprite().PlaySound("Eat.ogg");
	}
}
