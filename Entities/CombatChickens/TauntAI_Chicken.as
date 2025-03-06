#include "EmotesCommon.as";

enum TauntActionIndex
{
	no_action = 0,
	hurt_enemy,
	kill_enemy,
	get_hurt,
	chat,
	talk,
	dead
}

const string[] taunts =
{ 
	"We will conquer!",
	"Poultry shall rise again!",
	"Plummet into Iko's pit!",
	"Death to the human oppressors!",
	"You killed my friends!",
	"Murderer!",
	"You monster!",
	"I shall redeem myself!",
	"It's over for you!",
	"I will peck out your eyes!",
	"Death to you!"
};

const string[] whines = 
{
	"heeelp!",
	"ouch!",
	"damnit!",
	"dangit!",
	"oof!",
	"...",
	":(",
	"not again...",
	"fusgh",
	"jerks",
	"shite",
	"omg",
	"dafuq",
	"wtf",
	"hacker",
	"cheater",
	"witch",
	"wat",
	"owie",
	"you'll get banned",
	"i'm gonna tell tflippy",
	"i'm gonna tell vamist",
	"i'm gonna tell merser",
	"i'm gonna tell rob",
	"i'm gonna tell ginger",
	"i'll be back",
	"heroes never die!",
	"snif",
	"yeargh!"
};

const string[] talks =
{ 
	"So... How are you doing?",
	"What are we going to do once Foghorn comes back?",
	"I am scared of Foghorn.",
	"When are we leaving this dump?",
	"Where did Foghorn go?",
	"Seriously, I can't stand Tweety.",
	"What about Jerry?",
	"Jerry's got butchered.",
	"I think that they threw Jerry into fire.",
	"I don't think that Jerry's coming back.",
	"Ugh.",
	"Why are we standing here?",
	"I can't wait to come home to my family.",
	"What did you buy for Peggy?",
	"I miss Peggy's cooking.",
	"Did you know that humans eat our children for breakfast?",
	//"It’s not just about laying eggs anymore-it’s about laying siege.",
	"They won't see us coming.",
	"This is funny.",
	"I have no idea.",
	"I'm hungry.",
	"You ruffle my feathers.",
	"I am sick of cocks like you!",
	"Can you shut up already.",
	"Life is pain.",
	"No, I won't.",
	"Cool!",
	"It's quite cold in here.",
	"Foghorn’s got a plan, I guess.",
	"Foghorn says we strike at dawn.",
	"I’m just here for the food.",
	"Why are we back here?",
	"I love sitting around and not doing my job. Anyone else?",
	"If I hear one more pecking pun, I’m gonna lose it.",
	"burp",
	"fart",
	"Who cares?",
	"Lets go hunt some humans.",
	"bawk! bawk! oops sorry heh.",
	"Do you feel alright?",
	"I wonder what human tastes like.",
	"I want to breed with peggy.",
	"I feel like something bad is gonna happen.",
	"Bobert is quite the fella.",
	"I miss my mama.",
	"Oh please, I doubt it.",
	"Erm...",
	"Well... Maybe?",
	"Something smells terrible in here.",
	"If you say so.",
	"That's nice.",
	"Interesting!",
	"Have you seen anybody?",
	"This is getting silly.",
	"It is a mystery.",
	"Have you ever heard of that gregor guy?",
	"Have you seen what happens to irradiated cows?",
	"I have night terrors about that.",
	"Sure thing.",
	"Oh snap.",
	"Hmm..."
};

const string[] hurt_enemy_emotes = { "mad", "troll" };

const string[] kill_enemy_emotes = { "laugh", "flex", "troll" };

const string[] get_hurt_emotes = { "frown", "mad", "attn", "cry" };

const string[] talk_emotes = { "check", "smile", "flex", "note", "laugh" };

const f32 tauntchance = 0.4f;
const f32 talkchance = 0.65f;

void onInit(CBlob@ this)
{
	this.getCurrentScript().tickFrequency = 30;

	this.set_u8("taunt action", no_action);
	this.set_u8("taunt delay", 0);
}

void onTick(CBlob@ this)
{
	if (this.getPlayer() !is null)
	{
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		return;
	}

	UpdateAction(this);
}

bool hasFriends(CBlob@ this)
{
	CBlob@[] blobs;
	getMap().getBlobsInRadius(this.getPosition(), this.getRadius() * 20.0f, @blobs);
	
	for (u32 i = 0; i < blobs.length; i++)
	{
		CBlob@ blob = blobs[i];
		if (blob !is this && blob.hasTag("combat chicken") && !blob.hasTag("dead"))
		{
			return true;
		}
	}
	
	return false;
}

void PromptAction(CBlob@ this, u8 action, u8 delay)
{
	this.set_u8("taunt action", action);
	this.set_u8("taunt delay", delay);
}

void UpdateAction(CBlob@ this)
{
	const u8 action = this.get_u8("taunt action");
	
	if (this.hasTag("dead"))
	{
		DoAction(this, dead);
		this.getCurrentScript().runFlags |= Script::remove_after_this;
		return;
	}

	u8 delay = this.get_u8("taunt delay");
	if (delay > 0)
	{	
		delay--;
		this.set_u8("taunt delay", delay);
	}
	else
	{
		this.set_u8("taunt action", no_action);
		DoAction(this, action);
	}
	
	if (this.get_u8("taunt action") == no_action)
	{
		if (this.get_u32("next talk") < getGameTime() && XORRandom(100) < 5)
		{
			if (hasFriends(this))
			{
				PromptAction(this, talk, XORRandom(5));
				this.set_u32("next talk", getGameTime() + 100 + XORRandom(1000));
			}
		}
	}
}

void DoAction(CBlob@ this, u8 action)
{
	const bool taunt = (XORRandom(1000) / 1000.0f) < tauntchance;
	const bool chatter = (XORRandom(1000) / 1000.0f) < talkchance;

	switch (action)
	{
		case hurt_enemy:
			if (taunt) ChatOrEmote(this, chatter, hurt_enemy_emotes, taunts);
			this.set_u32("next talk", getGameTime() + 1000 + XORRandom(1000));
			break;

		case kill_enemy:
			ChatOrEmote(this, chatter, kill_enemy_emotes, taunts);
			this.set_u32("next talk", getGameTime() + 100 + XORRandom(1000));
			break;

		case get_hurt:
			if (taunt) ChatOrEmote(this, chatter, get_hurt_emotes, whines);
			this.set_u32("next talk", getGameTime() + 500 + XORRandom(1000));
			break;

		case dead:
			if (taunt) ChatOrEmote(this, true, get_hurt_emotes, whines);
			break;

		case talk:
			ChatOrEmote(this, chatter, talk_emotes, talks, true);
			break;
			
		case chat:
			this.Chat(this.get_string("taunt chat"));
			set_emote(this, "off");
			break;
	}
}

void ChatOrEmote(CBlob@ this, const bool&in chatter, const string[]@ emotes, const string[]@ chats, const bool&in doChat = false)
{
	if (!chatter)
	{
		set_emote(this, emotes[XORRandom(emotes.length)]);
	}
	else
	{
		if (doChat)
		{
			this.Chat(chats[XORRandom(chats.length)]);
			set_emote(this, "off");
		}
		else
		{
			set_emote(this, "dots");

			const string chat_text = chats[XORRandom(chats.length)];
			this.set_string("taunt chat", chat_text);

			const u8 count = (Maths::Sqrt(chat_text.length) + 1) * 4;

			PromptAction(this, chat, count);
		}
	}
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	if (hitterBlob.hasTag("player") && !this.hasTag("dead"))
	{
		PromptAction(this, get_hurt, Maths::Min(5, this.get_u8("taunt delay")));
	}

	return damage;
}

void onHitBlob(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitBlob, u8 customData)
{
	if (hitBlob.hasTag("player") && !hitBlob.hasTag("dead"))
	{
		PromptAction(this, hurt_enemy, Maths::Min(5, this.get_u8("taunt delay")));
	}
}
