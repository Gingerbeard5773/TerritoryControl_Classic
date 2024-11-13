#define CLIENT_ONLY

void onInit(CRules@ this)
{
	Driver@ driver = getDriver();
	driver.ForceStartShaders();
	driver.SetShader("hq2x", false);
	driver.AddShader("blurry", 500.0f);
	driver.SetShader("blurry", false);
}

void onTick(CRules@ this)
{
	Driver@ driver = getDriver();
	if (!driver.ShaderState()) 
	{
		driver.ForceStartShaders();
	}
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (player is getLocalPlayer())
	{
		getDriver().SetShader("blurry", false);
	}
}
