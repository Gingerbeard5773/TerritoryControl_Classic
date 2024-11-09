#define CLIENT_ONLY

void onInit(CRules@ this)
{
	Driver@ driver = getDriver();
	driver.SetShader("hq2x", false);
	driver.AddShader("blurry", 500.0f);
	driver.SetShader("blurry", false);
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (player is getLocalPlayer())
	{
		getDriver().SetShader("blurry", false);
	}
}
