//Ghost logic

void onInit(CBlob@ this)
{
	this.Tag("noUseMenu");
	this.set_f32("gib health", -3.0f);
	
	this.getShape().getConsts().mapCollisions = false;

	this.Tag("invincible");
	//this.Tag("player");

	CShape@ shape = this.getShape();
	shape.SetRotationsAllowed(false);
	shape.getConsts().net_threshold_multiplier = 0.5f;

	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	this.getCurrentScript().removeIfTag = "dead";
	
	this.SetLight(true);
	this.SetLightRadius(80.0f);
	this.SetLightColor(SColor(255, 255, 200, 0));
	
	ShakeScreen(64, 32, this.getPosition());
	ParticleZombieLightning(this.getPosition());
	this.getSprite().PlaySound("MagicWand.ogg");
	
	this.SetMapEdgeFlags(CBlob::map_collide_up | CBlob::map_collide_down | CBlob::map_collide_sides);
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		client_AddToChat(player.getUsername() + " is now in the Grandpa Administrator mode!", SColor(255, 255, 80, 150));
	}
}

void onDie(CBlob@ this)
{
	CPlayer@ player = this.getPlayer();
	if (player !is null)
	{
		client_AddToChat(player.getUsername() + " is no longer in the Grandpa Administrator mode!", SColor(255, 255, 80, 150));
	}

	ShakeScreen(64, 32, this.getPosition());
	ParticleZombieLightning(this.getPosition());
	this.getSprite().PlaySound("SuddenGib.ogg", 0.9f, 1.0f);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	return 0;
}

bool canBePutInInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	return false;
}
