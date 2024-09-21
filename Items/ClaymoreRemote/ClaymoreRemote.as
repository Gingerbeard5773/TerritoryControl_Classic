void onInit(CBlob@ this)
{
	this.addCommandID("server detonate");
	this.addCommandID("client detonate");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	caller.CreateGenericButton(11, Vec2f(0, 0), this, this.getCommandID("server detonate"), "Detonate!");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server detonate") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		this.SendCommand(this.getCommandID("client detonate"));

		CBlob@[] claymores;
		if (!getBlobsByName("claymore", @claymores)) return;

		for (int i = 0; i < claymores.length; i++)
		{
			CBlob@ claymore = claymores[i];
			CPlayer@ owner = claymore.getDamageOwnerPlayer();
			if (owner !is null && owner.getNetworkID() == player.getNetworkID())
			{
				if (claymore.get_u8("mine_state") == 1) // Primed?
				{
					// Yup, blow 'em away!
					claymore.Tag("exploding");
					claymore.Sync("exploding", true);

					claymore.server_SetHealth(-1.0f);
					claymore.server_Die();
				}
			}
		}
	}
	else if (cmd == this.getCommandID("client detonate") && isClient())
	{
		this.getSprite().PlaySound("mechanical_click.ogg", 4.0f);
	}
}
