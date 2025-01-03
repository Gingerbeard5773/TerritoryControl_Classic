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

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Gramophone));
	this.set_u8("trackID", 255);
	this.set_bool("isPlaying", false);
	
	this.addCommandID("sv_insert");
	this.addCommandID("sv_eject");
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("sv_insert") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		CBlob@ caller = player.getBlob();
		if (caller is null) return;

		CBlob@ carried = caller.getCarriedBlob();
		if (carried is null) return;
		
		if (this.get_bool("isPlaying")) return;

		if (carried.getName() == "musicdisc")
		{
			this.server_PutInInventory(carried);
		}
	}
	else if (cmd == this.getCommandID("sv_eject") && isServer())
	{
		CBlob@ disc = this.getInventory().getItem("musicdisc");
		if (disc is null) return;
		
		this.server_PutOutInventory(disc);
		disc.setVelocity(Vec2f(0, -8));
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (getMap().rayCastSolid(caller.getPosition(), this.getPosition())) return;

	if (this.get_bool("isPlaying"))
	{
		CButton@ buttonEject = caller.CreateGenericButton(9, Vec2f(0, 4), this, this.getCommandID("sv_eject"), "Eject");
	}
	else
	{
		CBlob@ carried = caller.getCarriedBlob();
		const bool isTrackValid = carried !is null && carried.getName() == "musicdisc";

		CButton@ buttonInsert = caller.CreateGenericButton(17, Vec2f(0, 4), this, this.getCommandID("sv_insert"), "Insert");
		buttonInsert.SetEnabled(isTrackValid);
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return false;
}

void onAddToInventory(CBlob@ this, CBlob@ blob)
{
	if (blob.getName() != "musicdisc") return;
	
	const u8 trackID = blob.get_u8("trackID");

	this.set_bool("isPlaying", true);
	this.set_u8("trackID", trackID);

	CSprite@ sprite = this.getSprite();
	sprite.RewindEmitSound();
	sprite.SetEmitSound(musicNames[trackID]);
	sprite.SetEmitSoundPaused(false);
	sprite.SetAnimation("track" + trackID);
}

void onRemoveFromInventory(CBlob@ this, CBlob@ blob)
{
	if (blob.getName() != "musicdisc") return;
	
	this.set_u8("trackID", 255); // Empty
	this.set_bool("isPlaying", false);

	CSprite@ sprite = this.getSprite();
	sprite.SetEmitSoundPaused(true);
	sprite.SetAnimation("empty");
}

void onThisAddToInventory(CBlob@ this, CBlob@ inventoryBlob)
{
	if (inventoryBlob is null) return;

	CInventory@ inv = inventoryBlob.getInventory();
	if (inv is null) return;

	this.doTickScripts = true;
	inv.doTickScripts = true;
}
