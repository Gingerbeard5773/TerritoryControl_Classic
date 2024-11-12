
// BulletMain.as - Vamist

//Gingerbeard @ November 9, 2024

#include "BulletClass.as";
#include "GunCommon.as";

BulletHolder@ BulletGrouped = BulletHolder();

const string[] bullet_types = { "TracerBullet.png", "TracerPlasma.png" };

const string[] bullet_fades = { "FadeBullet.png", "FadePlasma.png" };

Vertex[][] vertex_bullet_book(bullet_types.length);
Vertex[][] vertex_fade_book(bullet_fades.length);

f32 FRAME_TIME = 0;

void onInit(CRules@ this)
{
	Reset(this);

	if (isClient())
	{
		Render::addScript(Render::layer_postworld, "BulletMain", "RenderBullets", 0.0f);
	}

	onCreateBulletHandle@ onCreateBullet_ = @onCreateBullet;
	this.set("onCreateBullet handle", @onCreateBullet_);
}

void onRestart(CRules@ this)
{
	Reset(this);
}

void onReload(CRules@ this)
{
	onInit(this);
}

void Reset(CRules@ this)
{
	for (u8 i = 0; i < vertex_bullet_book.length; i++)
	{
		vertex_bullet_book[i].clear();
		vertex_fade_book[i].clear();
	}
	
	BulletGrouped.bullets.clear();
}

void onTick(CRules@ this)
{
	FRAME_TIME = 0;
	BulletGrouped.Tick();
}

void RenderBullets(int id)
{
	FRAME_TIME += getRenderApproximateCorrectionFactor();

	BulletGrouped.FillArray();

	Render::SetAlphaBlend(true);
	for (u8 i = 0; i < vertex_bullet_book.length; i++)
	{
		Vertex[]@ vertex_bullet = vertex_bullet_book[i];
		Vertex[]@ vertex_fade = vertex_fade_book[i];
		if (vertex_bullet.length == 0) continue; // Dont render if no bullets

		//Render bullet
		Render::RawQuads(bullet_types[i], vertex_bullet);
		
		//Render fade
		Render::RawQuads(bullet_fades[i], vertex_fade);

		if (g_debug == 0) // Useful for lerp testing
		{
			vertex_bullet.clear();
			vertex_fade.clear();
		}
	}
	Render::SetAlphaBlend(false);
}

void onCreateBullet(CBlob@ blob, f32 angle, Vec2f position, u32 time_spawned)
{
	Bullet bullet(blob, angle, position);

	CMap@ map = getMap();
	
	while (time_spawned++ < getGameTime()) // Catch up to everybody else
	{
		bullet.Tick(map);
	}

	BulletGrouped.AddNewBullet(bullet);
}
