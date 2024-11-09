#include "EquipmentCommon.as";
#include "RunnerTextures.as";
#include "MakeDustParticle.as";
#include "Knocked.as";
#include "FireParticle.as";
#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Jetpack));
	this.set_string("equipment_slot", "torso");

	addOnUnequip(this, @OnUnequip);
	addOnTickEquipped(this, @onTickEquipped);
	addOnTickSpriteEquipped(this, @onTickSpriteEquipped);
}

void OnUnequip(CBlob@ this, CBlob@ equipper)
{
	equipper.getSprite().RemoveSpriteLayer("jetpack");
}

void onTickEquipped(CBlob@ this, CBlob@ equipper)
{
	const u32 next_blastoff = this.get_u32("next_blastoff");
	if (next_blastoff < getGameTime())
	{
		CControls@ controls = equipper.getControls();
		if (controls !is null && controls.isKeyPressed(KEY_LSHIFT) && !isKnocked(equipper))
		{
			Vec2f dir = equipper.getAimPos() - equipper.getPosition();
			dir.Normalize();

			equipper.setVelocity(dir * 8.0f);

			if (isClient())
			{
				MakeDustParticle(equipper.getPosition() + Vec2f(2.0f, 4.0f), "Dust.png");
				equipper.getSprite().PlaySound("/Jetpack_Offblast.ogg");
			}

			this.set_u32("next_blastoff", getGameTime() + 90);
		}
	}

	if (isClient())
	{
		if ((getGameTime() + 75) < next_blastoff)
		{
			makeSteamParticle(equipper, Vec2f(), XORRandom(100) < 30 ? ("SmallFire" + (1 + XORRandom(2))) : "SmallExplosion" + (1 + XORRandom(3)));
		}
		else if (getGameTime() < next_blastoff)
		{
			Vec2f vel = Vec2f(XORRandom(128) - 64, XORRandom(128) - 64) * 0.0015f * equipper.getRadius();
			Vec2f offset = Vec2f(XORRandom(10) - 5, XORRandom(10) - 5) * 0.2f * equipper.getRadius();
			makeSteamParticle(equipper, vel, "SmallSteam", offset);
		}
	}
}

void onTickSpriteEquipped(CBlob@ this, CSprite@ equipper_sprite)
{
	CSpriteLayer@ jetpack = equipper_sprite.getSpriteLayer("jetpack");
	if (jetpack is null)
	{
		@jetpack = equipper_sprite.addSpriteLayer("jetpack", "jetpack.png", 16, 16);
		if (jetpack !is null)
		{
			jetpack.SetVisible(true);
			jetpack.SetRelativeZ(-2);
			jetpack.SetOffset(Vec2f(2, 0));
			if (equipper_sprite.isFacingLeft())
				jetpack.SetFacingLeft(true);
		}
	}

	if (jetpack !is null)
	{
		Vec2f headoffset(equipper_sprite.getFrameWidth() / 2, -equipper_sprite.getFrameHeight() / 2);
		Vec2f head_offset = getHeadOffset(equipper_sprite.getBlob(), -1, 0);
       
		headoffset += equipper_sprite.getOffset();
		headoffset += Vec2f(-head_offset.x, head_offset.y);
		headoffset += Vec2f(6, 4);
		jetpack.SetOffset(headoffset);
	}
}

void makeSteamParticle(CBlob@ this, const Vec2f vel, const string filename = "SmallSteam", const Vec2f displacement = Vec2f(0,0))
{
	if (!isClient()) return;
	ParticleAnimated(filename, this.getPosition() + displacement, vel, float(XORRandom(360)), 1.0f, 2 + XORRandom(3), -0.1f, false);
}
