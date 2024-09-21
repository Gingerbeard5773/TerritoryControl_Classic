#include "Hitters.as";
#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunInfo gun;

	gun.ammo_name = "mat_oil";
	gun.ammo_max = 50;
	
	gun.automatic = true;

	gun.projectile = "flame";
	gun.projectile_speed = 8.0f;
	gun.projectile_offset = Vec2f(0.0f, -4.0f);
	
	gun.fire_delay = 3;
	
	gun.reload_delay = 70;
	gun.reload_shotgun = false;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 0.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, 0.0f);

	gun.sound_fire = SoundInfo("FlamethrowerFire", 1.0f, 1.0f, 0);
	gun.sound_reload = SoundInfo("FlamethrowerReload", 1.0f, 0.65f, 0);
	gun.sound_cycle = SoundInfo("", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 0;
	gun.sound_loop = true;
	
	this.set("gunInfo", @gun);
}
