//Gingerbeard @ September 20, 2024

//This is a way to delay explosions if multiple happen at the same time
//The entire point is to attempt to stop players from disconnecting when large amounts of explosives go off.

//spammable/laggy explosives should be using this

void server_SetBombToExplode(CBlob@ this, const u16&in explosion_threshold = 5)
{
	if (!isServer() || this.hasTag("doExplode")) return;

	CRules@ rules = getRules();
	u16 explosion_count = rules.get_u16("explosion count");
	explosion_count += 1;
	if (explosion_count < explosion_threshold)
	{
		//instant explosion
		this.server_Die();
	}
	else
	{
		//delayed explosion
		const f32 ticks = f32(explosion_count + 1 - explosion_threshold) / 30.0f;
		this.server_SetTimeToDie(ticks);
	}
	rules.set_u16("explosion count", explosion_count);
}
