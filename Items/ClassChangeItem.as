void onInit(CBlob@ this)
{
	this.addCommandID("change class");
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getDistanceTo(this) > this.get_u8("class button radius")) return;

	if (caller.getName() == this.get_string("required class")) return;

	CButton@ button = caller.CreateGenericButton("$change_class$", this.get_Vec2f("class offset"), this, this.getCommandID("change class"), getTranslatedString("Swap Class"));
	button.enableRadius = this.get_u8("class button radius");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("change class") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		CBlob@ caller = player.getBlob();
		if (caller is null) return;

		if (caller.getName() == this.get_string("required class")) return;

		if (this.hasTag("used")) return;

		CBlob@ newBlob = server_CreateBlob(this.get_string("required class"), caller.getTeamNum(), this.getRespawnPosition());
		if (newBlob is null) return;

		// copy health and inventory
		CInventory@ inv = caller.getInventory();
		if (inv !is null)
		{
			caller.MoveInventoryTo(newBlob);
		}

		// set health to be same ratio
		float healthratio = caller.getHealth() / caller.getInitialHealth();
		newBlob.server_SetHealth(newBlob.getInitialHealth() * healthratio);

		// plug the soul
		newBlob.server_SetPlayer(caller.getPlayer());
		newBlob.setPosition(caller.getPosition());

		caller.Tag("switch class");
		caller.server_SetPlayer(null);
		caller.server_Die();

		this.Tag("used");
		this.server_Die();
	}
}
