#include "Hitters.as";
#include "GunCommon.as";

void onInit(CBlob@ this)
{
	GunInfo gun;

	gun.ammo_name = "mat_grenade";
	gun.ammo_max = 6;
	
	gun.automatic = false;

	gun.projectile = "grenade";
	gun.projectile_speed = 12.0f;
	gun.projectile_offset = Vec2f(0.0f, -2.0f);
	
	gun.fire_delay = 20;
	
	gun.reload_delay = 10;
	gun.reload_shotgun = true;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 3.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, 0.0f);

	gun.sound_fire = SoundInfo("GrenadeLauncherFire", 1.2f, 0.75f, 0);
	gun.sound_reload = SoundInfo("GrenadeLauncherCycle", 1.0f, 1.0f, 0);
	gun.sound_cycle = SoundInfo("", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 0;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
