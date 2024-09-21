//Small Sign
//written by Gingerbeard

void onInit(CBlob@ this)
{
	this.Tag("builder always hit");

	this.set_string("text", "!write -text-");

	this.addCommandID("server_write");
	this.addCommandID("client_write");
	this.addCommandID("server_addwrite");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("server_write") && isServer())
	{
		CBlob@ carried = getBlobByNetworkID(params.read_u16());
		if (carried is null) return;

		this.set_string("text", carried.get_string("text"));
		this.Sync("text", true);
		carried.server_Die();

		this.SendCommand(this.getCommandID("client_write"));
	}
	else if (cmd == this.getCommandID("server_addwrite") && isServer())
	{
		CBlob@ carried = getBlobByNetworkID(params.read_u16());
		if (carried is null) return;

		this.set_string("text", this.get_string("text") + " " + carried.get_string("text"));
		this.Sync("text", true);
		carried.server_Die();
	}
	else if (cmd == this.getCommandID("client_write") && isClient())
	{
		this.getSprite().SetAnimation("written");
	}
}

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = (blob.getRadius()) * 1.50f;
	const bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;

	if (getHUD().menuState != 0) return;

	CBlob@ localBlob = getLocalPlayerBlob();
	if (localBlob is null) return;

	if (((localBlob.getPosition() - center).Length() < 0.5f * (localBlob.getRadius() + blob.getRadius())) &&
	   (!getHUD().hasButtons()) || (mouseOnBlob))
	{
		Vec2f pos2d = blob.getScreenPos();
		int top = pos2d.y - 2.5f * blob.getHeight() + 0.0f; //y offset
		int left = 0.0f; //x offset
		if (blob.get_string("text").length >= 29) left = 150.0f; //set to side if string is too long
		int margin = 4;
		Vec2f dim;
		const string label = getTranslatedString(blob.get_string("text"))+"\n";
		GUI::SetFont("menu");
		GUI::GetTextDimensions(label , dim);
		dim.x = Maths::Min(dim.x, 200.0f);
		dim.x += margin;
		dim.y += margin;
		top += dim.y;
		Vec2f upperleft(pos2d.x - dim.x / 2 - left, top - Maths::Min(int(2 * dim.y), 250));
		Vec2f lowerright(pos2d.x + dim.x / 2 - left, top - dim.y);
		GUI::DrawText(label, Vec2f(upperleft.x + margin, upperleft.y + margin + margin),
		              Vec2f(upperleft.x + margin + dim.x, upperleft.y + margin + dim.y),
		              SColor(255, 0, 0, 0), false, false, true);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (this.getDistanceTo(caller) > this.getRadius()*3.0f) return;

	CBlob@ carried = caller.getCarriedBlob();
	if (carried !is null && carried.getName() == "paper")
	{
		CBitStream params;
		params.write_u16(carried.getNetworkID());

		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, 0), this, this.getCommandID("server_write"), "Write something on the sign.", params);

		if (this.get_string("text") != "!write -text-" && (this.get_string("text").length <= 200))
		{
			CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, -6), this, this.getCommandID("server_addwrite"), "Write another sentence.", params);
		}
	}
	else
	{
		CButton@ buttonWrite = caller.CreateGenericButton("$icon_paper$", Vec2f(0, 0), this, 0, "Write something on the sign.");
		buttonWrite.SetEnabled(false); 
	}
}
