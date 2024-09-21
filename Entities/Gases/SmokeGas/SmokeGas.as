void onInit(CBlob@ this)
{
	this.getShape().SetGravityScale(-0.1f);

	this.getSprite().SetZ(10.0f);

	this.SetMapEdgeFlags(CBlob::map_collide_sides);
	this.getCurrentScript().tickFrequency = 5;

	this.getSprite().RotateBy(90 * XORRandom(4), Vec2f());

	this.server_SetTimeToDie(6);
}

void onTick(CBlob@ this)
{
	if (this.getPosition().y < 0) this.server_Die();

	if (isClient())
	{
		MakeParticle(this);
	}
}

void MakeParticle(CBlob@ this, const string filename = "LargeSmoke")
{
	ParticleAnimated(CFileMatcher(filename).getFirst(), this.getPosition() + Vec2f(XORRandom(200) / 10.0f - 10.0f, XORRandom(200) / 10.0f - 10.0f), Vec2f(), float(XORRandom(360)), 1.0f + (XORRandom(50) / 100.0f), 3, 0.0f, false);
}

bool doesCollideWithBlob(CBlob@ this, CBlob@ blob)
{
   return blob.getName() == this.getName();
}
