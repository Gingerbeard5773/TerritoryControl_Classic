// A script by TFlippy & Pirate-Rob

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.set_string("text", "");

	this.addCommandID("server_write");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("server_write") && isServer())
	{
		CBlob@ carried = getBlobByNetworkID(params.read_netid());
		if (carried is null) return;

		this.set_string("text", carried.get_string("text"));
		this.Sync("text", true);

		carried.server_Die();
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();

	CCamera@ camera = getCamera();
	const f32 zoom = camera.targetDistance;
	if (zoom < 1) return;

	const string text = blob.get_string("text");
	Vec2f pos = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(0, -1));

	Vec2f dimensions;
	if (zoom == 2) GUI::SetFont("menu");
	GUI::GetTextDimensions(text, dimensions);

	GUI::DrawTextCentered(text, pos, SColor(255, 0, 0, 0));
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!this.isOverlapping(caller)) return;

	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null && carried.getName() == "paper")
	{
		CBitStream params;
		params.write_netid(carried.getNetworkID());
		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, 0), this, this.getCommandID("server_write"), "Write something on the sign.", params);
	}
}
