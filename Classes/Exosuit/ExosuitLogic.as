// Exosuit logic

#include "RunnerCommon.as";
#include "Hitters.as";
#include "HittersTC.as";
#include "Knocked.as";
//#include "ParticleSparks.as";

void onInit(CBlob@ this)
{
	this.set_f32("gib health", 0.0f);
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().net_threshold_multiplier = 0.5f;
	this.Tag("player");
	this.Tag("flesh");
	this.Tag("gas immune");

	this.set_u32("next warp", 0);
	
	this.set_u8("override head", 170);

	this.set_Vec2f("inventory offset", Vec2f(0.0f, 0.0f));

	this.getSprite().PlaySound("Exosuit_Equip.ogg", 1, 1);
	
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
	
	this.SetLight(false);
	this.SetLightRadius(64.0f);
	this.SetLightColor(SColor(255, 10, 250, 200));
}

void onInit(CSprite@ this)
{
	this.RemoveSpriteLayer("ghost");
	CSpriteLayer@ ghost = this.addSpriteLayer("ghost", "Exosuit_Ghost.png", 64, 24, this.getBlob().getTeamNum(), 0);
	if (ghost !is null)
	{
		ghost.SetRelativeZ(-1.0f);
		ghost.SetVisible(false);
	}
}

void onSetPlayer(CBlob@ this, CPlayer@ player)
{
	if (player !is null)
	{
		player.SetScoreboardVars("ScoreboardIcons.png", 3, Vec2f(16, 16));
	}
}

void onTick(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	const u32 time = getGameTime();
	
	if ((blob.get_u32("next warp") - 59) < time)
	{
		CSpriteLayer@ ghost = this.getSpriteLayer("ghost");

		this.setRenderStyle(RenderStyle::normal);
		//ghost.SetOffset(Vec2f(this.isFacingLeft() ? 16 : 48, 0.0f));
		ghost.SetVisible(false);
	}
	
	if (blob.isKeyPressed(key_action1)) this.setRenderStyle(RenderStyle::outline_front);
}

void onTick(CBlob@ this)
{
	if (this.isInInventory()) return;

	RunnerMoveVars@ moveVars;
	if (!this.get("moveVars", @moveVars)) return;

	const u32 time = getGameTime();
	Vec2f pos = this.getPosition();
	Vec2f aimpos = this.getAimPos();
	CMap@ map = getMap();
	
	bool pressed_a1 = this.isKeyPressed(key_action1);
	bool pressed_a2 = this.isKeyPressed(key_action2);

	moveVars.walkFactor *= 1.25f;
	moveVars.jumpFactor *= 1.50f;
	
	this.SetLight(pressed_a1);
	
	// if (isServer() && time % 90 == 0) this.server_Heal(0.25f); // OP
	
	const u8 knocked = getKnocked(this);
	if (knocked > 0) return;
		
	if (!pressed_a1 && pressed_a2 && this.get_u32("next warp") < time)
	{		
		Vec2f aimDir = pos - aimpos;
		aimDir.Normalize();

		HitInfo@[] hitInfos;
		Vec2f hitPos;
		
		map.rayCastSolid(pos, pos + (aimDir * -96.0f), hitPos);

		const f32 length = (hitPos - pos).Length();
		const f32 angle =	-aimDir.Angle() + 180;
	
		this.setPosition(hitPos);
		this.setVelocity(-aimDir * (length / 12.0f));
	
		if (isClient())
		{
			CSprite@ sprite = this.getSprite();
			sprite.PlaySound("Exosuit_Teleport.ogg", 1.0f, 1.0f);
			sprite.setRenderStyle(RenderStyle::additive);
			
			DrawGhost(sprite, length / 96, angle, this.isFacingLeft());
			ShakeScreen(64, 32, this.getPosition());	
		}
		
		if (isServer())
		{
			DestroyTileNoBedrock(map, hitPos, 32.0f);
			DestroyTileNoBedrock(map, hitPos + aimDir * -8, 16.0f);
			DestroyTileNoBedrock(map, hitPos + aimDir * -16, 8.0f);
			DestroyTileNoBedrock(map, hitPos + aimDir * -24, 4.0f);
			DestroyTileNoBedrock(map, hitPos + aimDir * -32, 2.0f);
			DestroyTileNoBedrock(map, hitPos + aimDir * -40, 1.0f);
			
			if (map.getHitInfosFromRay(pos, angle, length, this, @hitInfos))
			{
				for (int i = 0; i < hitInfos.length; i++)
				{
					CBlob@ blob = hitInfos[i].blob;
					if (blob is null) continue;

					if ((blob.isCollidable() || blob.hasTag("flesh")) && blob.getTeamNum() != this.getTeamNum()) 
					{
						this.server_Hit(blob, hitInfos[i].hitpos, Vec2f(0,0), 4.0f, Hitters::crush);
						SetKnocked(blob, length * 0.5f);
						blob.setVelocity(blob.getVelocity() + (-aimDir * (length / 12.0f)));
					}
				}
			}
		}
		
		this.set_u32("next warp", time + 60);
	}
}

void DestroyTileNoBedrock(CMap@ map, Vec2f position, const f32&in damage)
{
	if (!map.isTileBedrock(map.getTile(position).type))
	{
		map.server_DestroyTile(position, damage);
	}
}

void DrawGhost(CSprite@ this, const f32&in length, const f32&in angle, const bool&in flip)
{
	CSpriteLayer@ ghost = this.getSpriteLayer("ghost");

	ghost.ResetTransform();
	ghost.TranslateBy(Vec2f(length * (flip ? 1 : -1), 0));
	ghost.SetOffset(Vec2f(32, 0));
	ghost.RotateBy(angle + (flip ? 180 : 0), Vec2f(32 * (flip ? 1 : -1), 0.0f));
	ghost.SetVisible(true);
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	CPlayer@ player = this.getPlayer();
	
	if (this.hasTag("invincible") || (player !is null && player.freeze)) 
	{
		return 0;
	}
	
	switch (customData)
	{
		case Hitters::suicide:
			damage *= 10.0f;
			break;
	
		case Hitters::stab:
		case Hitters::sword:
		case Hitters::fall:
			damage *= 0.1f;
			break;
	
		case Hitters::explosion:
		case Hitters::keg:
		case Hitters::mine:
		case Hitters::mine_special:
		case Hitters::bomb:
			damage *= 0.7f;
			this.getSprite().PlaySound("Exosuit_Hit.ogg", 1, 1);			
			break;
	
		case Hitters::arrow:
		case HittersTC::bullet:
			damage *= 0.45f; 
			break;

		case Hitters::burn:
		case Hitters::fire:
		case Hitters::spikes:
		case Hitters::bite:
		case Hitters::builder:
			damage *= 0.00f;
			break;
			
		default:
			damage *= 0.60f;
			this.getSprite().PlaySound("Exosuit_Hit.ogg", 1, 1);		
			break;
	}

	if (hitterBlob !is null && hitterBlob !is this && this.isKeyPressed(key_action1) && !this.hasTag("noLMB"))
	{
		if (isServer())
		{
			this.server_Hit(hitterBlob, worldPoint, velocity, damage * 0.95f, customData);
		}

		hitterBlob.setVelocity(hitterBlob.getVelocity() + velocity * damage * 2);
		this.setVelocity(this.getVelocity() + velocity * damage);
		
		SetKnocked(hitterBlob, 20.0f * damage);
		SetKnocked(this, 10.0f * damage);
	
		if (isClient())
		{
			this.getSprite().PlaySound("Exosuit_Deflect.ogg", 1, 1);
			if (this.isMyPlayer()) SetScreenFlash(100, 255, 255, 255);			
		}

		return Maths::Min(0.05f, damage);
	}
	else
	{
		return damage;
	}
}

void onDie(CBlob@ this)
{
	if (isServer()) server_CreateBlob("exosuititem", this.getTeamNum(), this.getPosition());
	
	if (isClient()) this.getSprite().PlaySound("Exosuit_Dead.ogg");
}
