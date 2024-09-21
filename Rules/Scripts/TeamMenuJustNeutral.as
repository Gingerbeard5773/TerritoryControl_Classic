// show menu that only allows to join neutral

const int BUTTON_SIZE = 4;

void onInit(CRules@ this)
{
	this.addCommandID("server pick neutral");
}

void ShowTeamMenu(CRules@ this)
{
	CPlayer@ local = getLocalPlayer();
	if (local is null) return;

	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), null, Vec2f(BUTTON_SIZE, BUTTON_SIZE), "Change team");
	if (menu !is null)
	{
		CBitStream exitParams;
		menu.AddKeyCallback(KEY_ESCAPE, "TeamMenuJustNeutral.as", "Callback_PickNone", exitParams);
		menu.SetDefaultCallback("TeamMenuJustNeutral.as", "Callback_PickNone", exitParams);

		CGridButton@ button = menu.AddButton("$icon_ruins$", "Neutral", this.getCommandID("server pick neutral"), Vec2f(BUTTON_SIZE, BUTTON_SIZE));
	}
}

void Callback_PickNone(CBitStream@ params)
{
	getHUD().ClearMenus();
}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server pick neutral") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		CBlob@ b = player.getBlob();
		if (b !is null)
		{
			if (b.getName() == "slave") return;
			b.server_Die();
		}
	
		player.server_setTeamNum(100); //we set the actual team in TC_Rules.as
	}
}
