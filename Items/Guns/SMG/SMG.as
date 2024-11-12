#include "Hitters.as";
#include "GunCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::SMG));
	GunInfo gun;

	gun.ammo_name = "mat_pistolammo";
	gun.ammo_max = 30;
	
	gun.automatic = true;

	gun.projectile = "";
	gun.projectile_speed = 0.0f;
	gun.projectile_offset = Vec2f(0, 0);
	
	gun.bullet_damage = 0.5f;
	gun.bullet_range = 500.0f;
	gun.bullet_jitter = 1.0f;
	gun.bullet_count = 1;
	gun.bullet_pierce_factor = 0.8f;
	
	gun.fire_delay = 4;
	
	gun.reload_delay = 45;
	gun.reload_shotgun = false;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 3.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, -1.0f);
	gun.tracer_type = 0;
	
	gun.recoil_modifier = 0.9f;

	gun.sound_fire = SoundInfo("SMGFire", 1.0f, 1.0f, 0);
	gun.sound_reload = SoundInfo("SMGReload", 1.0f, 0.8f, 0);
	gun.sound_cycle = SoundInfo("", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 0;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
