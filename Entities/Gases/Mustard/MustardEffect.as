#include "Hitters.as";

void onInit(CBlob@ this)
{	
	if (this.isMyPlayer())
	{
		getDriver().SetShader("blurry", true);
	}
}

void onTick(CBlob@ this)
{
	const f32 mustard_value = this.get_f32("mustard value");
	
	if (this.hasTag("dead"))
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
	}
	
	if (this.isMyPlayer())
	{
		getDriver().SetShaderFloat("blurry", "blur_strength", mustard_value * 0.2f);
	}

	if (mustard_value >= 3)
	{
		const u32 ticks = getGameTime() - this.get_u32("mustard time");
		const f32 mod = mustard_value / 64.0f;
		const f32 mod_inv = Maths::Max(1.00f - mod, 0);		
		const u32 interval = 5 + u32(200 * mod_inv);
		if (ticks % interval == 0) 
		{
			if (isServer())
			{
				this.server_Hit(this, this.getPosition(), Vec2f(0, 0), Maths::Min(ticks, 300) * 0.00125f * mod, Hitters::burn);
			}
			if (isClient()) 
			{
				if (this.hasTag("player"))
				{
					this.getSprite().PlaySound("/cough" + XORRandom(5) + ".ogg", 0.6f, this.getSexNum() == 0 ? 1.0f : 2.0f);
					if (this.isMyPlayer()) ShakeScreen(60 * mod_inv, 5, this.getPosition());
				}
			}
		}
	}
	this.set_f32("mustard value", Maths::Max(mustard_value - 0.01f, 0));
}

void onDie(CBlob@ this)
{
	if (this.isMyPlayer())
	{
		getDriver().SetShader("blurry", false);
	}
}
