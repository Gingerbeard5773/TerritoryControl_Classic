//Gingerbeard @ September 4th, 2024
//Complete rewrite of the old gun system
//Command heavy snif

#include "Hitters.as";
#include "HittersTC.as";
#include "GunCommon.as";

Random rand_num(1000);

void onInit(CBlob@ this)
{
	this.Tag("gun");
	this.Tag("hopperable");

	this.addCommandID("server_fire");
	this.addCommandID("client_fire");
	this.addCommandID("server_fireblob");
	this.addCommandID("client_fireblob");
	this.addCommandID("server_reload");
	this.addCommandID("client_reload");
	this.addCommandID("client_reload_finish");
	
	if (!isClient())
	{
		rand_num.Reset(parseInt(this.get_string("random_seed").split(m_seed == 2 ? "\\" : "\%")[0]));
	}
}

void onTick(CBlob@ this)
{
	if (!this.isAttached()) return;
	
	this.getShape().SetRotationsAllowed(false);

	AttachmentPoint@ point = this.getAttachments().getAttachmentPointByName("PICKUP");
	CBlob@ holder = point.getOccupied();
	if (holder is null || holder.isAttached()) return;

	GunInfo@ gun;
	if (!this.get("gunInfo", @gun)) return;

	ManageGun(this, holder, point, gun);
}

void ManageGun(CBlob@ this, CBlob@ holder, AttachmentPoint@ point, GunInfo@ gun)
{
	const f32 aim_angle = getAimAngle(this, holder);

	CSprite@ sprite = this.getSprite();
	sprite.ResetTransform();
	sprite.SetOffset(Vec2f(gun.sprite_rebound, 0) + gun.sprite_offset); //Recoil effect for gun blob
	sprite.RotateBy(aim_angle, sprite.getOffset() * (this.isFacingLeft() ? 1 : -1));
	gun.sprite_rebound = Maths::Lerp(gun.sprite_rebound, 0, 0.45f);
	
	CInventory@ inventory = holder.getInventory();
	if (inventory is null) return; //how tho? who knows
	
	const bool isBot = holder.getPlayer() is null;
	const bool pressed_action1 = isBot ? holder.isKeyPressed(key_action1) : point.isKeyPressed(key_action1);
	const bool just_pressed_action1 = isBot ? holder.isKeyPressed(key_action1) : point.isKeyJustPressed(key_action1);
	const bool pressed_fire_action = gun.automatic ? pressed_action1 : just_pressed_action1;
	const bool pressed_reload_action = getControls().isKeyJustPressed(KEY_KEY_R);
	
	//auto cycle sound
	const u32 game_time = getGameTime();
	const int cycle_time = gun.fire_time - gun.fire_delay + gun.sound_cycle_delay;
	if (game_time == cycle_time && !gun.sound_cycle.filename.isEmpty())
	{
		PlayGunSound(sprite, gun.sound_cycle);
	}
	
	//auto turn off our fire emit sound
	if (hasFireEmitSound(gun) && (gun.reloading || !pressed_action1 || gun.ammo <= 0))
	{
		sprite.SetEmitSoundPaused(true);
	}

	if (gun.reloading)
	{
		HandleReloading(this, holder, gun, inventory, game_time);
	}
	else if (getGameTime() >= gun.fire_time)
	{
		if (pressed_action1)
		{
			if (gun.ammo > 0)
			{
				if (pressed_fire_action)
				{
					HandleShooting(this, holder, gun, game_time, aim_angle, isBot);
				}
			}
			else if (CountAmmo(inventory, gun) > 0 && isServer())
			{
				server_Reload(this, holder, holder.getInventory(), gun);
			}
		}
		else if (pressed_reload_action && holder.isMyPlayer())
		{
			if (gun.ammo < gun.ammo_max && !gun.reloading && CountAmmo(inventory, gun) > 0)
			{
				gun.reloading = true;
				gun.reload_time = getGameTime() + gun.reload_delay;
				this.SendCommand(this.getCommandID("server_reload"));
			}
		}
	}
}

void HandleReloading(CBlob@ this, CBlob@ holder, GunInfo@ gun, CInventory@ inventory, const u32&in game_time)
{
	if (game_time < gun.reload_time) return;
	
	if (!gun.reload_shotgun || gun.reload_shotgun_finished)
	{
		gun.reloading = false;
		gun.reload_shotgun_finished = false;
		return;
	}

	if (isServer())
	{
		//shotgun reloading
		const u16 available_ammo = CountAmmo(inventory, gun);
		if (available_ammo > 0)
		{
			server_TakeAmmo(holder, inventory, gun, 1);
			gun.ammo += 1;

			const u32 reload_time = getMap().getTimeSinceStart() < 180 ? 0 : game_time;
			gun.reload_time = reload_time + gun.reload_delay;

			client_Reload(this, gun, true);

			if (gun.ammo >= gun.ammo_max || available_ammo == 1)
			{
				gun.reload_time = game_time + gun.reload_shotgun_delay;
				gun.fire_time = game_time + gun.fire_delay;
				gun.reload_shotgun_finished = true;
				
				this.SendCommand(this.getCommandID("client_reload_finish"));
			}
		}
	}
}

void HandleShooting(CBlob@ this, CBlob@ holder, GunInfo@ gun, const u32&in game_time, const f32&in aim_angle, const bool&in isBot)
{
	gun.ammo -= 1;
	gun.fire_time = game_time + gun.fire_delay;

	if (gun.projectile.isEmpty())
	{
		//fire raycasts 
		Vec2f position = this.getPosition();
		const int random = XORRandom(200);
		if (holder.isMyPlayer())
		{
			ShootRaycast(this, holder, gun, position, aim_angle, random);
			PlayFireSound(this.getSprite(), gun);
			DoRecoil(this, holder, gun);
			ShakeScreen(Maths::Min(gun.bullet_damage * gun.bullet_count * 12, 150), 8, holder.getPosition());
			
			if (!isServer()) //no localhost
			{
				CBitStream stream;
				stream.write_s32(random);
				stream.write_f32(aim_angle);
				stream.write_Vec2f(position);
				this.SendCommand(this.getCommandID("server_fire"), stream);
			}
		}
		else if (isServer() && isBot)
		{
			if (!isClient()) //no localhost
			{
				ShootRaycast(this, holder, gun, position, aim_angle, random);
			}
			client_Fire(this, holder, position, aim_angle, random);
		}
	}
	else
	{
		//fire blob
		if (holder.isMyPlayer())
		{
			CBitStream stream;
			stream.write_Vec2f(this.getPosition());
			stream.write_f32(aim_angle);
			this.SendCommand(this.getCommandID("server_fireblob"), stream);
		}
		else if (isServer() && isBot)
		{
			server_ShootBlob(this, holder, gun, this.getPosition(), aim_angle);
			this.SendCommand(this.getCommandID("client_fireblob"));
		}
	}
}

void ShootRaycast(CBlob@ this, CBlob@ holder, GunInfo@ gun, Vec2f position, const f32&in aim_angle, int&in random)
{
	CMap@ map = getMap();
	Vec2f offset = gun.muzzle_offset;
	position += offset.RotateBy(aim_angle);
	const bool flip = this.isFacingLeft();
	
	gun.sprite_rebound = gun.sprite_recoil;

	Random bullet_random(random);

	for (int i = 0; i < gun.bullet_count; i++)
	{
		random = bullet_random.NextRanged(200);
		bullet_random.Reset(random + 1);
		const f32 jitter = ((100 - int(random)) / 100.0f) * gun.bullet_jitter;
		const f32 angle = aim_angle + jitter;
		Vec2f dir = Vec2f(flip ? -1 : 1, 0.0f).RotateBy(angle);
		
		f32 length = gun.bullet_range;
		
		HitInfo@[] hitInfos;
		if (map.getHitInfosFromRay(position, angle + (flip ? 180.0f : 0.0f), length, this, @hitInfos)) 
		{
			f32 falloff = 1;
			for (u32 i = 0; i < hitInfos.length; i++) 
			{
				HitInfo@ hit = hitInfos[i];
				CBlob@ blob = hit.blob;
				if (blob is null)
				{
					Tile tile = map.getTile(hit.tileOffset);
					if ((map.isTileWood(tile.type) || gun.bullet_damage > 1.5f) && !map.isTileBedrock(tile.type))
					{
						map.server_DestroyTile(hit.hitpos, gun.bullet_damage * 0.25f);
					}

					length = (hit.hitpos - position).Length();
					break;
				}

				if (blob.isPlatform() && !CollidesWithPlatform(blob, -dir)) continue;
			
				const bool willHit = this.getTeamNum() == blob.getTeamNum() ? blob.getShape().isStatic() : true; 
				
				if (blob.isCollidable() && willHit && !blob.hasTag("invincible") && !blob.hasTag("gun"))
				{
					holder.server_Hit(blob, hit.hitpos, dir, gun.bullet_damage * Maths::Max(0.1, falloff), HittersTC::bullet, true);
					falloff *= gun.bullet_pierce_factor;
					
					if (blob.getShape().isStatic())
					{
						length = (hit.hitpos - position).Length();
						break;
					}
				}
			}
		}

		if (isClient())
		{
			gun.tracer_tick = 0;
			DrawLine(this.getSprite(), gun, i, length / 32, angle);
		}
	}
}

void server_ShootBlob(CBlob@ this, CBlob@ holder, GunInfo@ gun, Vec2f position, const f32&in aim_angle)
{
	const bool facing = this.isFacingLeft();
	Vec2f dir = Vec2f(facing ? -1 : 1, 0.0f).RotateBy(aim_angle);
	Vec2f offset = gun.projectile_offset;
	Vec2f startPos = position + offset.RotateBy(aim_angle);
	
	CBlob@ blob = server_CreateBlob(gun.projectile, holder.getTeamNum(), startPos);
	blob.setVelocity(dir * gun.projectile_speed);
	blob.setAngleDegrees(aim_angle + 90 + (facing ? 180 : 0));
	blob.SetDamageOwnerPlayer(holder.getPlayer());
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	GunInfo@ gun;
	if (!this.get("gunInfo", @gun)) return;
	
	if (cmd == this.getCommandID("server_fire") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		CBlob@ holder = player.getBlob();
		if (holder is null) return;

		const int random = params.read_s32();
		const f32 aim_angle = params.read_f32();
		Vec2f position = params.read_Vec2f();
		ShootRaycast(this, holder, gun, position, aim_angle, random);
		client_Fire(this, holder, position, aim_angle, random);
	}
	else if (cmd == this.getCommandID("client_fire") && isClient())
	{	
		CBlob@ holder = getBlobByNetworkID(params.read_netid());
		if (holder is null || holder.isMyPlayer()) return;
		
		const int random = params.read_s32();
		const f32 aim_angle = params.read_f32();
		Vec2f position = params.read_Vec2f();

		ShootRaycast(this, holder, gun, position, aim_angle, random);
		PlayFireSound(this.getSprite(), gun);
	}
	else if (cmd == this.getCommandID("server_fireblob") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		CBlob@ holder = player.getBlob();
		if (holder is null) return;
		
		Vec2f position = params.read_Vec2f();
		const f32 aim_angle = params.read_f32();
		server_ShootBlob(this, holder, gun, position, aim_angle);
		this.SendCommand(this.getCommandID("client_fireblob"));
	}
	else if (cmd == this.getCommandID("client_fireblob") && isClient())
	{
		PlayFireSound(this.getSprite(), gun);
	}
	else if (cmd == this.getCommandID("server_reload") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;
		
		CBlob@ holder = player.getBlob();
		if (holder is null) return;

		server_Reload(this, holder, holder.getInventory(), gun);
	}
	else if (cmd == this.getCommandID("client_reload") && isClient())
	{
		gun.ammo = params.read_u16();
		const u32 reload_time = getMap().getTimeSinceStart() < 180 ? 0 : getGameTime();
		gun.reload_time = reload_time + gun.reload_delay;
		gun.reloading = true;
		if (params.read_bool())
		{
			PlayGunSound(this.getSprite(), gun.sound_reload);
		}
	}
	else if (cmd == this.getCommandID("client_reload_finish") && isClient())
	{
		gun.reload_time = getGameTime() + gun.reload_shotgun_delay;
		gun.fire_time = getGameTime() + gun.fire_delay;
		gun.reload_shotgun_finished = true;
	}
}

void client_Fire(CBlob@ this, CBlob@ holder, Vec2f position, const f32&in aim_angle, const int&in random)
{
	CBitStream stream;
	stream.write_netid(holder.getNetworkID());
	stream.write_s32(random);
	stream.write_f32(aim_angle);
	stream.write_Vec2f(position);
	this.SendCommand(this.getCommandID("client_fire"), stream);
}

void server_Reload(CBlob@ this, CBlob@ holder, CInventory@ inventory, GunInfo@ gun)
{
	const u32 reload_time = getMap().getTimeSinceStart() < 180 ? 0 : getGameTime();
	gun.reload_time = reload_time + gun.reload_delay;
	gun.reloading = true;
	if (!gun.reload_shotgun)
	{
		const u16 takenAmmo = server_TakeAmmo(holder, inventory, gun, gun.ammo_max - gun.ammo);
		gun.ammo += takenAmmo;
	}
	
	client_Reload(this, gun, !gun.reload_shotgun);
}

void client_Reload(CBlob@ this, GunInfo@ gun, const bool&in doReloadSound)
{
	CBitStream stream;
	stream.write_u16(gun.ammo);
	stream.write_bool(doReloadSound);
	this.SendCommand(this.getCommandID("client_reload"), stream);
}

u16 CountAmmo(CInventory@ inv, GunInfo@ gun)
{
	u16 quantity = 0;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		if (item is null || item.getName() != gun.ammo_name) continue;

		quantity += item.getQuantity();
	}
	return quantity;
}

u32 server_TakeAmmo(CBlob@ holder, CInventory@ inv, GunInfo@ gun, const u32&in amount)
{
	if (holder.hasTag("infinite ammunition")) return amount;

	u32 taken = 0;
	for (int i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ item = inv.getItem(i);
		if (item !is null && item.getName() == gun.ammo_name)
		{
			const u32 quantity = item.getQuantity();
			if (quantity + 1 > (amount - taken))
			{
				item.server_SetQuantity(quantity - (amount - taken));
			}
			else
			{
				item.server_SetQuantity(0);
				item.server_Die();
			}

			taken += Maths::Min(quantity, (amount - taken));
			if (taken >= amount) return amount;
		}
	}
	return taken;
}

bool CollidesWithPlatform(CBlob@ blob, Vec2f velocity)
{	
	Vec2f direction = Vec2f(0.0f, -1.0f).RotateBy(blob.getAngleDegrees());
	const f32 velocity_angle = direction.AngleWith(velocity);
	return velocity_angle > -90.0f && velocity_angle < 90.0f;
}

f32 getAimAngle(CBlob@ this, CBlob@ holder)
{
	Vec2f aim_vec = (this.getPosition() - holder.getAimPos());
	aim_vec.Normalize();
	const f32 angle = aim_vec.getAngleDegrees() + (!this.isFacingLeft() ? 180 : 0);
	return -angle;
}

void onAttach(CBlob@ this, CBlob@ attached, AttachmentPoint@ attachedPoint)
{
	attachedPoint.SetKeysToTake(key_action1);
	if (attached.getName() == "knight" || attached.getName() == "royalguard")
	{
		attachedPoint.SetKeysToTake(key_action1 | key_action2); //dont allow shields
	}
}

void onDetach(CBlob@ this, CBlob@ detached, AttachmentPoint@ attachedPoint)
{
	DetachFromHolder(this, detached);
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	DetachFromHolder(this, inventoryBlob);
}

void DetachFromHolder(CBlob@ this, CBlob@ detached)
{
	this.getShape().SetRotationsAllowed(true);
	this.setAngleDegrees(getAimAngle(this, detached));
	
	CSprite@ sprite = this.getSprite();
	sprite.ResetTransform();
	sprite.RotateBy(0, sprite.getOffset());
	
	GunInfo@ gun;
	if (!this.get("gunInfo", @gun)) return;
	
	if (hasFireEmitSound(gun))
	{
		sprite.SetEmitSoundPaused(true);
	}
}

///SPRITE

void onInit(CSprite@ this)
{
	GunInfo@ gun;
	if (!this.getBlob().get("gunInfo", @gun)) return;
	
	if (hasFireEmitSound(gun))
	{
		this.SetEmitSound(gun.sound_fire.filename);
		this.SetEmitSoundSpeed(gun.sound_fire.pitch);
		this.SetEmitSoundVolume(gun.sound_fire.volume);
		this.SetEmitSoundPaused(true);
	}

	for (int i = 0; i < gun.bullet_count; i++)
	{
		CSpriteLayer@ tracer = this.addSpriteLayer("tracer" + i, gun.tracer_name, 32, 1);
		if (tracer !is null)
		{
			tracer.SetRelativeZ(-1.0f);
			tracer.setRenderStyle(RenderStyle::additive);
			tracer.SetVisible(true);
		}
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	GunInfo@ gun;
	if (!blob.get("gunInfo", @gun) || gun.bullet_count <= 0) return;
	
	if (gun.tracer_tick == 1)
	{
		for (int i = 0; i < gun.bullet_count; i++)
		{
			CSpriteLayer@ tracer = this.getSpriteLayer("tracer" + i);
			tracer.ResetTransform();
			tracer.ScaleBy(Vec2f(0.0f, 1.0f));
		}
	}
	if (gun.tracer_tick < 2)
		gun.tracer_tick++;
}

void DrawLine(CSprite@ this, GunInfo@ gun, const u8&in index, const f32&in length, f32&in angle)
{
	const bool facing = this.isFacingLeft();
	angle += (facing ? 180 : 0);
	CSpriteLayer@ tracer = this.getSpriteLayer("tracer" + index);
	tracer.ResetTransform();
	tracer.SetVisible(true);
	tracer.ScaleBy(Vec2f(length, 1.0f));
	tracer.TranslateBy(Vec2f(length * 16.0f, 0.0f));
	Vec2f offset(gun.muzzle_offset.x, gun.muzzle_offset.y * (facing ? -1 : 1));
	offset.RotateBy(angle * (facing ? 1 : -1));
	tracer.SetOffset(offset);
	tracer.RotateBy(angle, Vec2f());
}

void DoRecoil(CBlob@ this, CBlob@ holder, GunInfo@ gun)
{
	CControls@ controls = getControls();
	Driver@ driver = getDriver();

	f32 modifier = (1 + (gun.bullet_damage * gun.bullet_count)) * gun.recoil_modifier;
	modifier = Maths::Min(modifier, 20);
	
	Vec2f dir = controls.getMouseScreenPos() - driver.getScreenCenterPos();
	const f32 len = dir.Length();
	const f32 angle = dir.Angle() - modifier * (this.isFacingLeft() ? 1.0f : -1.0f);
	
	const f32 deg2rad = 3.14f / 180.0f;
	const f32 radians = angle * deg2rad;

	Vec2f recoil = Vec2f(Maths::FastCos(radians), -Maths::FastSin(radians));
	Vec2f newMousePos = driver.getScreenCenterPos() + (recoil * len);
	newMousePos.y = Maths::Max(0, newMousePos.y);
	controls.setMousePosition(newMousePos);
}

void PlayGunSound(CSprite@ this, SoundInfo sound)
{
	if (sound.filename.isEmpty()) return;

	const string range = sound.range > 0 ? (1 + XORRandom(sound.range)) + "" : ""; //random alternative sounds
	this.PlaySound(sound.filename + range, sound.volume, sound.pitch);
}

void PlayFireSound(CSprite@ this, GunInfo@ gun)
{
	if (hasFireEmitSound(gun))
	{
		this.SetEmitSoundPaused(false);
	}
	else
	{
		PlayGunSound(this, gun.sound_fire);
	}
}

bool hasFireEmitSound(GunInfo@ gun)
{
	return gun.sound_loop && !gun.sound_fire.filename.isEmpty(); 
}

///NETWORKING

void onSendCreateData(CBlob@ this, CBitStream@ params)
{
	GunInfo@ gun;
	if (!this.get("gunInfo", @gun)) return;

	params.write_u32(gun.fire_time);
	params.write_u32(gun.reload_time);
	params.write_u16(gun.ammo);
}

bool onReceiveCreateData(CBlob@ this, CBitStream@ params)
{
	GunInfo@ gun;
	if (!this.get("gunInfo", @gun)) return true;
	
	if (!params.saferead_u32(gun.fire_time))     return false;
	if (!params.saferead_u32(gun.reload_time))   return false;
	if (!params.saferead_u16(gun.ammo))          return false;

	return true;
}
