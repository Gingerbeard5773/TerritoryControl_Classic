#include "Hitters.as";
#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunInfo gun;

	gun.ammo_name = "mat_rifleammo";
	gun.ammo_max = 5;
	
	gun.automatic = true;

	gun.projectile = "";
	gun.projectile_speed = 0.0f;
	gun.projectile_offset = Vec2f(0, 0);
	
	gun.bullet_damage = 3.5f;
	gun.bullet_range = 600.0f;
	gun.bullet_jitter = 0.0f;
	gun.bullet_count = 1;
	gun.bullet_pierce_factor = 0.8f;
	
	gun.fire_delay = 40;
	
	gun.reload_delay = 75;
	gun.reload_shotgun = false;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 5.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, -1.0f);
	gun.tracer_name = "GatlingGun_Tracer.png";

	gun.sound_fire = SoundInfo("RifleFire", 1.0f, 1.0f, 0);
	gun.sound_reload = SoundInfo("RifleReload", 1.0f, 1.0f, 0);
	gun.sound_cycle = SoundInfo("RifleCycle", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 20;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
