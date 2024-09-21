#include "Hitters.as";
#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunInfo gun;

	gun.ammo_name = "mat_mithril";
	gun.ammo_max = 3;
	
	gun.automatic = true;

	gun.projectile = "";
	gun.projectile_speed = 0.0f;
	gun.projectile_offset = Vec2f(0, 0);
	
	gun.bullet_damage = 4.0f;
	gun.bullet_range = 500.0f;
	gun.bullet_jitter = 0.2f;
	gun.bullet_count = 2;
	gun.bullet_pierce_factor = 0.8f;
	
	gun.fire_delay = 5;
	
	gun.reload_delay = 20;
	gun.reload_shotgun = false;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 5.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, -1.0f);
	gun.tracer_name = "ChargeLance_Tracer.png";
	
	gun.recoil_modifier = 0.65f;

	gun.sound_fire = SoundInfo("ChargeRifle_Shoot", 1.5f, 1.0f, 4);
	gun.sound_reload = SoundInfo("ChargeRifle_Reload", 1.5f, 1.0f, 0);
	gun.sound_cycle = SoundInfo("", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 0;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
