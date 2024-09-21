// A script by TFlippy

const string[] names =
{
	"Blank",
	"Mountain King",
	"Lucio",
	"The Flying Circus",
	"It is a Mystery",
	"No Hushing",
	"Circus!",
	"Hot Stuff",
	"Maple Leaf",
	"Drunken Sailor",
	"Suite Punta del Este",
	"Fly Me to the Moon",
	"Homeward Bound",
	"Welcome to My Lair",
	"Viva Las Vegas",
	"Daddy Cool",
	"Carry on Wayward Son",
	"Odd Couple",
	"Bandit Radio",
	"Let the Sunshine in",
	"Tea for Two"
};

void onInit(CBlob@ this)
{
	if (!this.exists("trackID")) this.set_u8("trackID", XORRandom(names.length)); // Temporary 

	const u8 trackID = this.get_u8("trackID");
	
	this.set_u8("trackID", trackID);
	this.getSprite().SetAnimation("track" + trackID);
	this.setInventoryName("Gramophone Record (" + (trackID < names.length ? names[trackID] : "ERROR") + ")");
}