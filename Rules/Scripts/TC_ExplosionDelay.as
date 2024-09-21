//Gingerbeard @ September 20, 2024

#define SERVER_ONLY;

//consult ExplosionDelay.as

void onInit(CRules@ this)
{
	this.set_u16("explosion count", 0);
}

void onTick(CRules@ this)
{
	u16 explosion_count = this.get_u16("explosion count");
	explosion_count = Maths::Max(explosion_count - 1, 0);
	this.set_u16("explosion count", explosion_count);
}
