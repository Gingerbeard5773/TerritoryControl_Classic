#include "Hitters.as";
#include "GunCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Revolver));
	GunInfo gun;

	gun.ammo_name = "mat_pistolammo";
	gun.ammo_max = 6;
	
	gun.automatic = false;

	gun.projectile = "";
	gun.projectile_speed = 0.0f;
	gun.projectile_offset = Vec2f(0, 0);
	
	gun.bullet_damage = 0.82f;
	gun.bullet_range = 450.0f;
	gun.bullet_jitter = 2.0f;
	gun.bullet_count = 1;
	gun.bullet_pierce_factor = 0.8f;
	
	gun.fire_delay = 5;
	
	gun.reload_delay = 55;
	gun.reload_shotgun = false;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 3.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, -1.0f);
	gun.tracer_name = "GatlingGun_Tracer.png";

	gun.sound_fire = SoundInfo("RevolverFire", 1.0f, 1.0f, 0);
	gun.sound_reload = SoundInfo("RevolverReload", 1.0f, 1.0f, 0);
	gun.sound_cycle = SoundInfo("", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 0;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
