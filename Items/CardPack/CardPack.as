
void onInit(CBlob@ this)
{
	this.addCommandID("server useitem");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	CButton@ button = caller.CreateGenericButton(12, Vec2f_zero, this, this.getCommandID("server useitem"), "Open the pack and see what's inside!");
	button.SetEnabled(this.isAttachedTo(caller));
}

const string[] cards =
{
	"holy_cards",
	"chaos_cards",
	"fire_cards",
	"water_cards",
	"cog_cards",
	"steam_cards",
	"nature_cards",
	"mine_cards",
	"death_cards"
};

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server useitem") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		CBlob@ caller = player.getBlob();
		if (caller is null) return;
	
		if (this.hasTag("opened")) return;

		for (int i = 0; i < 8; i++)
		{
			const string name = cards[XORRandom(cards.length)];
			CBlob@ blob = server_CreateBlob(name, -1, this.getPosition());
			if (blob !is null)
			{
				blob.server_SetQuantity(1);
				if (!caller.server_PutInInventory(blob))
				{
					blob.setPosition(caller.getPosition());
				}
			}
		}

		this.Tag("opened");
		this.server_Die();
	}
}
