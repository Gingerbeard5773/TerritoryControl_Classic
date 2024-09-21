#include "MaterialCommon.as";

const string[] insertNames =
{
	"mat_copper",
	"mat_iron",
	"mat_gold",
	"mat_ironingot",
	"mat_coal"
};

const string[] matNames =
{ 
	"mat_copper",
	"mat_iron",
	"mat_gold"
};

const string[] matNamesResult =
{ 
	"mat_copperingot",
	"mat_ironingot",
	"mat_goldingot"
};

const int[] matRatio =
{ 
	10,
	10,
	25
};

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getCurrentScript().tickFrequency = 60;
	
	this.Tag("ignore extractor");
	this.Tag("builder always hit");
}

void onTick(CBlob@ this)
{
	if (this.hasBlob("mat_ironingot", 4) && this.hasBlob("mat_coal", 1)) //steel ingots require coal!
	{
		if (isServer())
		{
			server_MakeIngot(this, "mat_steelingot");
			this.TakeBlob("mat_ironingot", 4);
			this.TakeBlob("mat_coal", 1);
		}

		this.getSprite().PlaySound("ProduceSound.ogg");
		this.getSprite().PlaySound("BombMake.ogg");
	}

	for (int i = 0; i < 3; i++)
	{
		if (this.hasBlob(matNames[i], matRatio[i]))
		{
			if (isServer())
			{
				server_MakeIngot(this, matNamesResult[i]);
				this.TakeBlob(matNames[i], matRatio[i]);
			}
			
			this.getSprite().PlaySound("ProduceSound.ogg");
			this.getSprite().PlaySound("BombMake.ogg");
		}
	}
}

void server_MakeIngot(CBlob@ this, const string&in ingot_name)
{
	CBlob@ mat = server_CreateBlobNoInit(ingot_name);
	mat.setPosition(this.getPosition());
	mat.Tag("custom quantity");
	mat.set_u32("autopick time", getGameTime() +  getTicksASecond() * 10);
	mat.server_SetQuantity(1);
	mat.Init();
	this.IgnoreCollisionWhileOverlapped(mat);
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;
	
	if (!blob.isAttached() && blob.hasTag("material") && insertNames.find(blob.getName()) != -1 && blob.getTickSinceCreated() > 5)
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return ((forBlob.getTeamNum() == this.getTeamNum() || this.getTeamNum() >= getRules().getTeamsCount()) && forBlob.isOverlapping(this));
}
