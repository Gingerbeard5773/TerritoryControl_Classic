//GunCommon.as
//Gingerbeard @ September 4th, 2024

shared class GunInfo
{
	string ammo_name;                //ammo the gun takes
	u16 ammo_max;                    //maximum amount of ammo the gun can hold
	u16 ammo;                        //current ammo

	bool automatic;                  //fire automatic? (determines if you have to press the button each time to fire)

	string projectile;               //blob projectile we fire- leave blank for bullets
	f32 projectile_speed;            //velocity speed given to fired projectile
	Vec2f projectile_offset;         //offset where the projectile spawns

	f32 bullet_damage;               //damage done to blobs
	f32 bullet_range;                //distance the bullet goes
	f32 bullet_jitter;               //accuracy
	u32 bullet_count;                //how many bullets do we fire
	f32 bullet_pierce_factor;        //damage multiplier with each consecutive hit

	u32 fire_delay;                  //ticks between shots
	u32 fire_time;                   //next gametime we can fire

	u32 reload_delay;                //ticks it takes to reload
	u32 reload_time;                 //next gametime when reloading is finished
	bool reloading;                  //is the gun currently reloading
	bool reload_shotgun;             //do we reload like a shotgun?
	u32 reload_shotgun_delay;        //additional delay to reload end
	bool reload_shotgun_finished;    //we are ending the reload

	f32 sprite_rebound;              //gun blow back effect
	f32 sprite_recoil;               //how much the gun's sprite will blow back
	Vec2f sprite_offset;             //offset for the sprite
	u8 tracer_type;                  //index for the gun's bullet tracer

	Vec2f muzzle_offset;             //offset to set the muzzle of the gun

	f32 recoil_modifier;             //value that can be used to altar how strong the gun's (cursor) recoil is 

	SoundInfo sound_fire;            //shoot sound
	SoundInfo sound_reload;          //reload sound
	SoundInfo sound_cycle;           //sound when 'cycling' a new round
	u32 sound_cycle_delay;           //ticks to do the cycling sound
	bool sound_loop;                 //do we use an emitsound instead?

	GunInfo()
	{
		ammo_name = "mat_rifleammo";
		ammo_max = 1;
		ammo = 0;

		automatic = false;

		projectile = "";
		projectile_speed = 0.0f;
		projectile_offset = Vec2f(0, 0);

		bullet_damage = 1.0f;
		bullet_range = 1.0f;
		bullet_jitter = 0.0f;
		bullet_count = 1;
		bullet_pierce_factor = 0.8f;

		fire_delay = 1;
		fire_time = 0;

		reload_delay = 1;
		reload_time = 0;
		reloading = false;
		reload_shotgun = false;
		reload_shotgun_delay = 0;
		reload_shotgun_finished = false;
		
		sprite_rebound = 0.0f;
		sprite_recoil = 5.0f;
		sprite_offset = Vec2f(0, 0);
		tracer_type = 0;

		muzzle_offset = Vec2f(0, 0);

		recoil_modifier = 1.0f;

		sound_fire = SoundInfo();
		sound_reload = SoundInfo();
		sound_cycle = SoundInfo();
		sound_cycle_delay = 0;
		sound_loop = false;
	}
};

shared class SoundInfo
{
	string filename;
	f32 volume;
	f32 pitch;
	u32 range;

	SoundInfo()
	{
		filename = "";
		volume = 1.0f;
		pitch = 1.0f;
		range = 0;
	}
	SoundInfo(const string&in filename, const f32&in volume, const f32&in pitch, const u32&in range)
	{
		this.filename = filename;
		this.volume = volume;
		this.pitch = pitch;
		this.range = range;
	}
};

funcdef void onCreateBulletHandle(CBlob@, f32, Vec2f, u32);

void CreateBullet(CBlob@ blob, const f32&in angle, const Vec2f&in position, const u32&in time_spawned) 
{
	onCreateBulletHandle@ onCreateBullet;
	if (getRules().get("onCreateBullet handle", @onCreateBullet))
	{
		onCreateBullet(blob, angle, position, time_spawned);
	}
}
