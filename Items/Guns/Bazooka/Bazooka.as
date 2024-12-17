#include "Hitters.as";
#include "GunCommon.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Bazooka));
	GunInfo gun;

	gun.ammo_name = "mat_smallrocket";
	gun.ammo_max = 1;
	
	gun.automatic = false;

	gun.projectile = "smallrocket";
	gun.projectile_speed = 8.0f;
	gun.projectile_offset = Vec2f(5.5f, -2.0f);
	
	gun.fire_delay = 40;
	
	gun.reload_delay = 50;
	gun.reload_shotgun = false;
	gun.reload_shotgun_delay = 0;
	
	gun.sprite_recoil = 0.0f;
	gun.sprite_offset = this.getSprite().getOffset();
	gun.muzzle_offset = Vec2f(0.0f, 0.0f);

	gun.sound_fire = SoundInfo("BazookaFire", 1.0f, 1.0f, 0);
	gun.sound_reload = SoundInfo("BazookaReload", 1.0f, 0.63f, 0);
	gun.sound_cycle = SoundInfo("BazookaCycle", 1.0f, 1.0f, 0);
	gun.sound_cycle_delay = 25;
	gun.sound_loop = false;
	
	this.set("gunInfo", @gun);
}
