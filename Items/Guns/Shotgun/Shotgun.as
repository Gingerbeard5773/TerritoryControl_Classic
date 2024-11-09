#include "Hitters.as";
#include "GunCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Shotgun));
	GunInfo gun;

	gun.ammo_name = "mat_shotgunammo";
	gun.ammo_max = 4;
	
	gun.automatic = true;

	gun.projectile = "";
	gun.projectile_speed = 0.0f;
	gun.projectile_offset = Vec2f(0, 0);
	
	gun.bullet_damage = 0.75f;
	gun.bullet_range = 500.0f;
	gun.bullet_jitter = 4.0f;
	gun.bullet_count = 6;
	gun.bullet_pierce_factor = 0.8f;
	
	gun.fire_delay = 35;
	
	gun.reload_delay = 10;
	gun.reload_shotgun = true;
	gun.reload_shotgun_delay = 49;
	
	gun.sprite_recoil = 5.0f;
	gun.sprite_offset = Vec2f(0, 0);
	gun.muzzle_offset = Vec2f(0.0f, -1.0f);
	gun.tracer_name = "GatlingGun_Tracer.png";

	gun.sound_fire = SoundInfo("ShotgunFire", 1.0f, 1.0f, 5);
	gun.sound_reload = SoundInfo("ShotgunReload", 0.6f, 1.0f, 0);
	gun.sound_cycle = SoundInfo("ShotgunPump", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 16;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
