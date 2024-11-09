#include "Hitters.as";
#include "GunCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::BanditRifle));
	GunInfo gun;

	gun.ammo_name = "mat_banditammo";
	gun.ammo_max = 4;
	
	gun.automatic = false;

	gun.projectile = "";
	gun.projectile_speed = 0.0f;
	gun.projectile_offset = Vec2f(0, 0);
	
	gun.bullet_damage = 0.5f;
	gun.bullet_range = 250.0f;
	gun.bullet_jitter = 7.5f;
	gun.bullet_count = 4;
	gun.bullet_pierce_factor = 0.8f;
	
	gun.fire_delay = 5;
	
	gun.reload_delay = 20;
	gun.reload_shotgun = true;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 4.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, -1.0f);
	gun.tracer_name = "GatlingGun_Tracer.png";

	gun.sound_fire = SoundInfo("BanditRifleFire", 1.0f, 0.8f, 0);
	gun.sound_reload = SoundInfo("thud", 1.0f, 1.5f, 0);
	gun.sound_cycle = SoundInfo("", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 0;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
