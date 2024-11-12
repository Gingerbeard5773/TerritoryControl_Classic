#include "Hitters.as";
#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunInfo gun;

	gun.ammo_name = "mat_gatlingammo";
	gun.ammo_max = 150;
	
	gun.automatic = true;

	gun.projectile = "";
	gun.projectile_speed = 0.0f;
	gun.projectile_offset = Vec2f(0, 0);
	
	gun.bullet_damage = 1.75f;
	gun.bullet_range = 500.0f;
	gun.bullet_jitter = 1.5f;
	gun.bullet_count = 1;
	gun.bullet_pierce_factor = 0.8f;
	
	gun.fire_delay = 3;
	
	gun.reload_delay = 5;
	gun.reload_shotgun = false;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 5.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, 0.0f);
	gun.tracer_type = 0;

	gun.sound_fire = SoundInfo("Minigun_Shoot", 2.0f, 1.0f, 0);
	gun.sound_reload = SoundInfo("SMGReload", 1.0f, 0.8f, 0);
	gun.sound_cycle = SoundInfo("", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 0;
	gun.sound_loop = true;
	
	this.set("gunInfo", @gun);
}
