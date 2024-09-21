// Draw an emoticon

#include "EmotesCommon.as";

void onInit(CBlob@ blob)
{
	blob.addCommandID("emote");

	CSprite@ sprite = blob.getSprite();
	blob.set_string("emote", "");
	blob.set_u32("emotetime", 0);

	dictionary@ packs;
	if (!getRules().get("emote packs", @packs)) return;
	string[] tokens = packs.getKeys();

	for (uint i = 0; i < tokens.size(); i++)
	{
		EmotePack@ pack;
		packs.get(tokens[i], @pack);

		//init emote layer
		CSpriteLayer@ layer = sprite.addSpriteLayer("bubble" + pack.token, pack.filePath, 32, 32, blob.getTeamNum(), 0);
		layer.SetIgnoreParentFacing(true);
		layer.SetFacingLeft(false);

		if (layer !is null)
		{
			layer.SetOffset(Vec2f(0, -sprite.getBlob().getRadius() * 1.5f - 16));
			layer.SetRelativeZ(100.0f);
			{
				Animation@ anim = layer.addAnimation("default", 0, true);

				for (int i = 0; i < pack.emotes.size(); i++)
				{
					anim.AddFrame(i);
				}
			}
			layer.SetVisible(false);
			layer.SetHUD(true);
		}
	}
}

void onTick(CBlob@ blob)
{
	blob.getCurrentScript().tickFrequency = 6;

	if (!blob.getShape().isStatic())
	{
		dictionary@ packs;
		if (!getRules().get("emote packs", @packs)) return;
		string[] tokens = packs.getKeys();

		Emote@ emote = getEmote(blob.get_string("emote"));
		DoEmoteVoice(blob, emote);

		for (uint i = 0; i < tokens.size(); i++)
		{
			EmotePack@ pack;
			packs.get(tokens[i], @pack);

			CSpriteLayer@ layer = blob.getSprite().getSpriteLayer("bubble" + pack.token);
			if (layer is null) continue;

			bool visible = false;

			bool correctPack = emote !is null && emote.pack.token == pack.token;
			bool shouldDisplay = is_emote(blob);
			bool canDisplay = !blob.hasTag("dead") && !blob.isInInventory();

			if (correctPack && shouldDisplay && canDisplay)
			{
				blob.getCurrentScript().tickFrequency = 1;

				visible = !isMouseOverEmote(layer);
				layer.animation.frame = emote.index;

				layer.ResetTransform();

				CCamera@ camera = getCamera();
				if (camera !is null)
				{
					f32 angle = -camera.getRotation() + blob.getAngleDegrees();
					layer.RotateBy(-angle, Vec2f(0, 20));
				}
			}

			layer.SetVisible(visible);
		}
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	// For now, this is just a command for setting emote for crates
	if (cmd == this.getCommandID("emote") && isServer())
	{
		CPlayer@ p = getNet().getActiveCommandPlayer();
		if (p is null) return;

		CBlob@ b = p.getBlob();
		if (b is null) return;

		if (b !is this) return;

		if (this.isInInventory())
		{
			CBlob@ inventoryblob = this.getInventoryBlob();
			if (inventoryblob !is null && inventoryblob.getName() == "crate"
				&& inventoryblob.exists("emote"))
			{
				inventoryblob.set_string("emote", b.get_string("emote"));
				inventoryblob.Sync("emote", true);
				inventoryblob.set_u32("emotetime", b.get_u32("emotetime"));
				inventoryblob.Sync("emotetime", true);
			}
		}
	}
}

void DoEmoteVoice(CBlob@ this, Emote@ emote)
{
	if (!isClient() || emote is null) return;
	
	if (getGameTime() != this.get_u32("emotetime") - 88) return;

	if (emote.index < sounds.length && getGameTime() >= this.get_u32("next_emote_sound") && sounds[emote.index] != "")
	{
		f32 pitch = this.getSexNum() == 0 ? 0.9f : 1.5f;
		if (this.exists("voice pitch")) pitch = this.get_f32("voice pitch");

		this.getSprite().PlaySound(sounds[emote.index], 0.80f, pitch);
		
		this.set_u32("next_emote_sound", getGameTime() + 20);
	}
}

string[] sounds = 
{
	"vo_rip",                           // skull,     //0
	"vo_join",                          // blueflag,
	"vo_lalala_2",                      // note,
	"vo_look",                          // right,
	"vo_yes",                           // smile,
	"vo_join",                          // redflag,
	"vo_strong",                        // flex,
	"vo_look",                          // down,
	"vo_no",                            // frown,
	"vo_haha",                          // troll,
	"vo_jerk",                          // finger,    //10
	"vo_look",                          // left,
	"vo_grrr",                          // mad,
	"vo_archer",                        // archer,
	"vo_water",                         // sweat,
	"vo_look",                          // up,
	"vo_haha",                          // laugh,
	"vo_knight",                        // knight,
	"vo_huh",                           // question,
	"vo_yes",                           // thumbsup,
	"vo_what",                          // wat,       //20
	"vo_builder",                       // builder,
	"vo_bad",                           // disappoint,
	"vo_no",                            // thumbsdown,
	"vo_uhh",                           // derp,
	"vo_ladder",                        // ladder,
	"vo_help",                          // attn,
	"vo_okay",                          // ok,
	"vo_uhh",                           // cry,
	"vo_build",                         // wall,
	"vo_hi",                            // heart,     //30
	"vo_fire",                          // fire,
	"vo_okay",                          // check,
	"vo_okay",                          // cool,
	"",                                 // dots,
	"",                                 // cog,
	"vo_what",                          // think
	"vo_haha",                          // laughcry,
	"vo_lag",                           // derp,
	"vo_haha",                          // awkward,
	"vo_idiot"                          // smug,      //40
	"",                                 // love,
	"",                                 // kiss,
	"",                                 // pickup,
	"vo_what",                          // raised,
	"",                                 // clap,
	"",                                 // 
	"",                                 // emotes_total,
	"",                                 // off
};
