#include "Hitters.as";
#include "GunCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::ChargeLance));
	GunInfo gun;

	gun.ammo_name = "mat_lancerod";
	gun.ammo_max = 3;
	
	gun.automatic = true;

	gun.projectile = "";
	gun.projectile_speed = 0.0f;
	gun.projectile_offset = Vec2f(0, 0);
	
	gun.bullet_damage = 100.0f;
	gun.bullet_range = 600.0f;
	gun.bullet_jitter = 0.4f;
	gun.bullet_count = 8;
	gun.bullet_pierce_factor = 0.8f;
	
	gun.fire_delay = 100;
	
	gun.reload_delay = 120;
	gun.reload_shotgun = false;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 8.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, -1.0f);
	gun.tracer_type = 1;

	gun.sound_fire = SoundInfo("ChargeLanceFire", 1.5f, 1.0f, 3);
	gun.sound_reload = SoundInfo("ChargeLanceReload", 1.5f, 1.0f, 0);
	gun.sound_cycle = SoundInfo("ChargeLanceCycle", 1.5f, 1.0f, 0);
	gun.sound_cycle_delay = 20;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
