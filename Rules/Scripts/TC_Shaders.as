#define CLIENT_ONLY

#include "ShockwaveCommon.as";

void onInit(CRules@ this)
{
	Driver@ driver = getDriver();
	driver.ForceStartShaders();
	driver.SetShader("hq2x", false);
	driver.AddShader("shockwave", 5.0f);
	driver.SetShader("shockwave", false);
	driver.AddShader("drunk", 10.0f);
	driver.SetShader("drunk", false);
	driver.AddShader("blurry", 20.0f);
	driver.SetShader("blurry", false);
	
	Shockwave@[] shockwaves;
	this.set("shockwaves", shockwaves);
}

void onTick(CRules@ this)
{
	Driver@ driver = getDriver();
	if (!driver.ShaderState()) 
	{
		driver.ForceStartShaders();
	}
}

void onRender(CRules@ this)
{
	if (v_fastrender) return;

	Shockwave@[]@ shockwaves;
	if (!this.get("shockwaves", @shockwaves)) return;
	
	Driver@ driver = getDriver();
	if (shockwaves.length == 0)
	{
		driver.SetShader("shockwave", false);
		return;
	}
	
	Vec2f screen = driver.getScreenDimensions();
	driver.SetShader("shockwave", true);
	driver.SetShaderFloat("shockwave", "screen_width", screen.x);
	driver.SetShaderFloat("shockwave", "screen_height", screen.y);

	for (int i = 0; i < shockwaves.length; i++)
	{
		Shockwave@ shockwave = shockwaves[i];
		const f32 time = (getGameTime() - shockwave.time_started) / 30.0f;
		if (time > 10)
		{
			shockwaves.erase(i);
			i--;
			continue;
		}
		
		Vec2f screen_pos = driver.getScreenPosFromWorldPos(shockwave.world_pos);
		Vec2f screen_uv(screen_pos.x / screen.x, 1.0f - (screen_pos.y / screen.y));

		driver.SetShaderFloat("shockwave", "shockwaves["+i+"].x", screen_uv.x);
		driver.SetShaderFloat("shockwave", "shockwaves["+i+"].y", screen_uv.y);
		driver.SetShaderFloat("shockwave", "shockwaves["+i+"].time", time);
		driver.SetShaderFloat("shockwave", "shockwaves["+i+"].intensity", shockwave.intensity);
		driver.SetShaderFloat("shockwave", "shockwaves["+i+"].falloff", shockwave.falloff);
	}
	driver.SetShaderFloat("shockwave", "count", shockwaves.length);
}

void onSetPlayer(CRules@ this, CBlob@ blob, CPlayer@ player)
{
	if (player is getLocalPlayer())
	{
		Driver@ driver = getDriver();
		driver.SetShader("drunk", false);
		driver.SetShader("blurry", false);
	}
}
