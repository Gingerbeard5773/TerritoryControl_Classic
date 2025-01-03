void onInit(CBlob@ this)
{
	if (!this.exists("text"))
		this.set_string("text", "");
	this.setInventoryName(this.get_string("text"));
}

void onRender(CSprite@ this)
{	
	CBlob@ blob = this.getBlob();
	Vec2f center = blob.getPosition();
	Vec2f mouseWorld = getControls().getMouseWorldPos();
	const f32 renderRadius = blob.getRadius() * 2.0f;
	const bool mouseOnBlob = (mouseWorld - center).getLength() < renderRadius;
	
	if (mouseOnBlob)
	{
		const string text = blob.get_string("text");
		Vec2f pos = getDriver().getScreenPosFromWorldPos(blob.getPosition() + Vec2f(0, -14));
		
		Vec2f dimensions;
		GUI::SetFont("menu");
		GUI::GetTextDimensions(text, dimensions);
		
		const f32 padding = 7.5f;
		Vec2f tl = pos - Vec2f(dimensions.x / 2 + padding, dimensions.y / 2 + padding);
		Vec2f br = pos + Vec2f(dimensions.x / 2 + padding, dimensions.y / 2 + padding);
		GUI::DrawWindow(tl, br);
		GUI::DrawTranslatedTextCentered(text, pos + Vec2f(0, -padding), SColor(255, 0, 0, 0));
	}
}
