#define SERVER_ONLY

void onInit(CRules@ this)
{
	Reset(this);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void Reset(CRules@ this)
{
	this.set_u32("next_meteor", getNextMeteor());
	this.set_u32("next_wreckage", getNextWreckage());
}

u32 getNextMeteor()
{
	return 6000 + XORRandom(29000);
}

u32 getNextWreckage()
{
	return 60000 + XORRandom(80000);
}

void onTick(CRules@ this)
{
	if (getGameTime() % 30 == 0)
	{
		CMap@ map = getMap();
		const u32 time = getGameTime();
		const u32 nextMeteor = this.get_u32("next_meteor");
		const u32 nextWreckage = this.get_u32("next_wreckage");

		if (time >= nextMeteor)
		{
			print("Random event: Meteor");
			server_CreateBlob("meteor", -1, Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));

			this.set_u32("next_meteor", time + getNextMeteor());
		}

		if (time >= nextWreckage)
		{
			print("Random event: Wreckage");
			server_CreateBlob("ancientship", -1, Vec2f(XORRandom(map.tilemapwidth) * map.tilesize, 0.0f));

			this.set_u32("next_wreckage", time + getNextWreckage());
		}
	}
}
