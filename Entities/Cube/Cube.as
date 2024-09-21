const f32 soundMaxDist = 256.0f;

void onInit(CSprite@ this)
{
	Animation@ anim = this.addAnimation("default", 1, true);
	{
		int[] frames(300);
		for (int i = 0; i < 300; i++)
		{
			frames[i] = i;
		}
		anim.AddFrames(frames);
	}
	this.SetAnimation(anim);
}

void onInit(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSound("Cube.ogg");
	sprite.RewindEmitSound();
	sprite.SetEmitSoundPaused(false);

	this.set_f32("camX", 0);
	this.set_f32("camY", 0);
	this.set_f32("camZ", 0);
}

void onTick(CBlob@ this)
{
	CBlob@ playerBlob = getLocalPlayerBlob();
	if (playerBlob !is null)
	{
		f32 dist = (playerBlob.getPosition() - this.getPosition()).getLength();
		dist /= soundMaxDist;
		if (dist > 1.0f) dist = 1.0f;
		dist = 1.0f - dist;
		this.getSprite().SetEmitSoundVolume(dist);

		f32 camX = this.get_f32("camX");
		f32 camY = this.get_f32("camY");
		f32 camZ = this.get_f32("camZ");

		camX = Maths::Sin(getGameTime() / 40.0f) * 0.5f * (dist);
		camY = Maths::Cos(getGameTime() / 45.0f) * 0.5f * (dist);
		camZ = Maths::Sin(getGameTime() / 35.0f) * 0.5f * (dist);

		CCamera@ cam = getCamera();
		cam.setRotation(camX, camY, camZ);

		this.set_f32("camX", camX);
		this.set_f32("camY", camY);
		this.set_f32("camZ", camZ);
	}
}

void onDie(CBlob@ this)
{
	getCamera().setRotation(0.0f, 0.0f, 0.0f);
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	CInventory@ inv = inventoryBlob.getInventory();
	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}
