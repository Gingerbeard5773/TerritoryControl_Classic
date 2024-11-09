// A script by TFlippy

#include "TC_Translation.as";

const string[] musicNames =
{
	"Disc_Blank.ogg",
	"Disc_MountainKing.ogg",
	"Disc_Lucio.ogg",
	"Disc_MontyPython.ogg",
	"Disc_Mystery.ogg",
	"Disc_NoHushing.ogg",
	"Disc_Circus.ogg",
	"Disc_HotStuff.ogg",
	"Disc_MapleLeaf.ogg",
	"Disc_DrunkenSailor.ogg",
	"Disc_SuitePuntaDelEste.ogg",
	"Disc_FlyMeToTheMoon.ogg",
	"Disc_HomewardBound.ogg",
	"Disc_WelcomeToMyLair.ogg",
	"Disc_VivaLasVegas.ogg",
	"Disc_DaddyCool.ogg",
	"Disc_CarryOnWaywardSon.ogg",
	"Disc_OddCouple.ogg",
	"Disc_Bandit.ogg",
	"Disc_LetTheSunshineIn.ogg",
	"Disc_TeaForTwo.ogg"
};

// 255 = no disc

const int DiscNum = 20;

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Gramophone));
	this.set_u8("trackID", 255);
	this.set_bool("isPlaying", false);
	
	this.addCommandID("sv_insert");
	this.addCommandID("sv_eject");
	this.addCommandID("cl_play");
	this.addCommandID("cl_stop");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (isServer())
	{
		if (cmd == this.getCommandID("sv_insert"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller is null) return;

			CBlob@ carried = caller.getCarriedBlob();
			if (carried is null) return;
			
			if (this.get_bool("isPlaying") || getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
			bool isTrackValid = carried.getName() == "musicdisc" && carried.get_u8("trackID") >= 0 && carried.get_u8("trackID") < DiscNum + 1;
			if (isTrackValid)
			{
				u8 trackID = carried.get_u8("trackID");
				
				// print("insert " + musicNames[trackID]);
				
				this.set_u8("trackID", trackID);
				this.set_bool("isPlaying", true);
				
				CBitStream stream;
				stream.write_u8(trackID);

				carried.server_Die();
				this.SendCommand(this.getCommandID("cl_play"), stream);
			}
		}
		else if (cmd == this.getCommandID("sv_eject"))
		{
			CBlob@ caller = getBlobByNetworkID(params.read_u16());
			if (caller is null) return;
			
			if (getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
			
			this.set_bool("isPlaying", false);
			
			CBlob@ disc = server_CreateBlobNoInit("musicdisc");
			disc.setPosition(this.getPosition() + Vec2f(0, -4));
			disc.set_u8("trackID", this.get_u8("trackID"));
			disc.setVelocity(Vec2f(0, -8));
			disc.server_setTeamNum(-1);
			disc.Init();
			
			CBitStream stream;
			this.SendCommand(this.getCommandID("cl_stop"), stream);	
		}
	}
	
	if (isClient())
	{
		if (cmd == this.getCommandID("cl_play"))
		{
			u8 trackID = params.read_u8();
			bool isTrackValid = trackID >= 0 && trackID < DiscNum + 1;
			
			// print("play " + musicNames[trackID]);
			
			if (isTrackValid)
			{
				this.set_bool("isPlaying", true);
				this.set_u8("trackID", trackID);
			
				CSprite@ sprite = this.getSprite();
				sprite.RewindEmitSound();
				sprite.SetEmitSound(musicNames[trackID]);
				sprite.SetEmitSoundPaused(false);
				sprite.SetAnimation("track" + trackID);
			}
		}
		else if (cmd == this.getCommandID("cl_stop"))
		{
			this.set_u8("trackID", 255); // Empty
			this.set_bool("isPlaying", false);
		
			CSprite@ sprite = this.getSprite();
			sprite.SetEmitSoundPaused(true);
			sprite.SetAnimation("empty");
		}
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;
	
	CBitStream params;
	params.write_u16(caller.getNetworkID());

	if (this.get_bool("isPlaying"))
	{
		CButton@ buttonEject = caller.CreateGenericButton(9, Vec2f(0, 4), this, this.getCommandID("sv_eject"), "Eject", params);
	}
	else
	{
		CBlob@ carried = caller.getCarriedBlob();
		bool isTrackValid = carried !is null && carried.getName() == "musicdisc" && carried.get_u8("trackID") >= 0 && carried.get_u8("trackID") < DiscNum + 1;

		CButton@ buttonInsert = caller.CreateGenericButton(17, Vec2f(0, 4), this, this.getCommandID("sv_insert"), "Insert", params);
		buttonInsert.SetEnabled(isTrackValid);
	}
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();

	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}

void onDie(CBlob@ this)
{
	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
}