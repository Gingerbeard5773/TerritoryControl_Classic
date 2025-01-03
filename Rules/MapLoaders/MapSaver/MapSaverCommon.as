// SonantDread & Gingerbeard @ January 2nd 2025

#include "MakeScroll.as";
#include "MakeSeed.as";
#include "MakeCrate.as";
#include "GunCommon.as";

/*
 HOW TO SAVE CUSTOM BLOB DATA FOR YOUR MOD
 1) Create a blob handler class for your blob, with the applicable functions.
 2) Then set the class with the associated blob name into InitializeBlobHandlers().
 3) Delete the save file every time you modify blob handlers- doing this will avoid crashes caused by faulty data reading
*/

//nuke (boom time)

const string SaveFile = "TC_Save_";

dictionary blobHandlers;
dictionary blobTagHandlers;
void InitializeBlobHandlers()
{
	if (blobHandlers.getSize() != 0) return;

	blobHandlers.set("default",       BlobDataHandler());
	blobHandlers.set("seed",          SeedBlobHandler());
	blobHandlers.set("crate",         CrateBlobHandler());
	blobHandlers.set("scroll",        ScrollBlobHandler());
	blobHandlers.set("lever",         LeverBlobHandler());

	blobHandlers.set("tree_bushy",    TreeBlobHandler());
	blobHandlers.set("tree_pine",     TreeBlobHandler());

	//TC

	blobHandlers.set("meteor",        MeteorBlobHandler());
	blobHandlers.set("ancientship",   WreckageBlobHandler());
	blobHandlers.set("nuke",          NukeBlobHandler());
	blobHandlers.set("musicdisc",     DiscBlobHandler());
	
	blobHandlers.set("bomber",        BomberBlobHandler());
	blobHandlers.set("armoredbomber", BomberBlobHandler());
	
	blobHandlers.set("scoutchicken",  BotBlobHandler());
	blobHandlers.set("scyther",       BotBlobHandler());

	blobHandlers.set("textsign",      SignBlobHandler());
	blobHandlers.set("smallsign",     SignBlobHandler());
	blobHandlers.set("paper",         SignBlobHandler());

	blobHandlers.set("builder",       PlayerBlobHandler());
	blobHandlers.set("archer",        PlayerBlobHandler());
	blobHandlers.set("knight",        PlayerBlobHandler());
	blobHandlers.set("peasant",       PlayerBlobHandler());
	blobHandlers.set("slave",         PlayerBlobHandler());
	blobHandlers.set("bandit",        PlayerBlobHandler());
	blobHandlers.set("royalguard",    PlayerBlobHandler());
	blobHandlers.set("exosuit",       PlayerBlobHandler());

	blobHandlers.set("rifle",         GunBlobHandler());
	blobHandlers.set("revolver",      GunBlobHandler());
	blobHandlers.set("smg",           GunBlobHandler());
	blobHandlers.set("shotgun",       GunBlobHandler());
	blobHandlers.set("scorcher",      GunBlobHandler());
	blobHandlers.set("bazooka",       GunBlobHandler());
	blobHandlers.set("banditrifle",   GunBlobHandler());
	blobHandlers.set("banditpistol",  GunBlobHandler());
	blobHandlers.set("chargerifle",   GunBlobHandler());
	blobHandlers.set("chargelance",   GunBlobHandler());
}

bool canSaveBlob(CBlob@ blob)
{
	const string name = blob.getName();
	if (name == "spike" || name == "tc_music") return false;

	if (blob.hasTag("temp blob") || blob.hasTag("dead") || blob.hasTag("projectile")) return false;

	return true;
}

BlobDataHandler@ basicHandler = BlobDataHandler();
class BlobDataHandler
{
	// Write our blob's information into the config
	// Each piece of data must be divided by the token ';'
	string Serialize(CBlob@ blob)
	{
		string data = blob.getName() + ";";
		CShape@ shape = blob.getShape();
		Vec2f pos = blob.getPosition();
		data += pos.x + ";" + pos.y + ";";
		data += blob.getHealth() + ";";
		data += blob.getTeamNum() + ";";
		data += shape !is null && shape.isStatic() ? "1;" : "0;";
		data += blob.getAngleDegrees() + ";";
		data += blob.getQuantity() + ";";
		data += blob.isFacingLeft() ? "1;" : "0;";
		return data;
	}

	// Creation protocols for the particular blob
	// Necessary because some blobs must have data set to the blob *before* the blob is initialized. 
	CBlob@ CreateBlob(const string&in name, const Vec2f&in pos, const string[]@ data)
	{
		return server_CreateBlob(name, 0, pos);
	}

	// Load in any special properties/states for the particular blob
	// Note; all other classes will need updated if you change the amount of data that is processed in this base class
	void LoadBlobData(CBlob@ blob, const string[]@ data)
	{
		const f32 health = parseFloat(data[3]);
		const int team = parseInt(data[4]);
		const bool isStatic = parseBool(data[5]);
		const f32 angle = parseFloat(data[6]);
		const u16 quantity = parseInt(data[7]);
		const bool facingLeft = parseBool(data[8]);

		blob.server_SetHealth(health);
		blob.server_setTeamNum(team);
		blob.setAngleDegrees(angle);

		CShape@ shape = blob.getShape();
		if (shape !is null)
		{
			shape.SetStatic(isStatic);
		}

		blob.server_SetQuantity(quantity);
		blob.SetFacingLeft(facingLeft);
	}
}

class SeedBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		data += blob.get_string("seed_grow_blobname") + ";";
		return data;
	}

	CBlob@ CreateBlob(const string&in name, const Vec2f&in pos, const string[]@ data) override
	{
		const string seedName = data[9];
		return server_MakeSeed(pos, seedName);
	}
}

class CrateBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		const string packed = blob.exists("packed") ? blob.get_string("packed") : "";
		if (!packed.isEmpty())
		{
			data += packed + ";";
		}
		return data;
	}

	CBlob@ CreateBlob(const string&in name, const Vec2f&in pos, const string[]@ data) override
	{
		CBlob@ crate = server_CreateBlobNoInit("crate");
		crate.setPosition(pos);
		const string packed = data.length > 9 ? data[9] : "";
		if (!packed.isEmpty())
		{
			crate.set_string("packed", packed);
		}
		crate.Init();
		return crate;
	}
}

class ScrollBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		data += blob.get_string("scroll defname0") + ";";
		return data;
	}

	CBlob@ CreateBlob(const string&in name, const Vec2f&in pos, const string[]@ data) override
	{
		const string scroll_name = data[9];
		return server_MakePredefinedScroll(pos, scroll_name);
	}
}

class LeverBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		data += (blob.get_bool("activated") ? "1;" : "0;");
		return data;
	}

	void LoadBlobData(CBlob@ blob, const string[]@ data) override
	{
		basicHandler.LoadBlobData(blob, data);
		const bool activated = parseBool(data[9]);
		blob.set_bool("activated", activated);
	}
}

class TreeBlobHandler : BlobDataHandler
{
	CBlob@ CreateBlob(const string&in name, const Vec2f&in pos, const string[]@ data) override
	{
		CBlob@ blob = server_CreateBlobNoInit(name);
		blob.setPosition(pos);
		blob.Tag("startbig");
		blob.Init();
		return blob;
	}
}

class MeteorBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		data += blob.get_s32("heat") + ";";
		return data;
	}
	
	void LoadBlobData(CBlob@ blob, const string[]@ data) override
	{
		basicHandler.LoadBlobData(blob, data);
		const int heat = data.length > 9 ? parseInt(data[9]) : 0;
		blob.set_s32("heat", heat);
	}
}

class WreckageBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		data += blob.hasTag("scyther inside") ? "1;" : "0;";
		return data;
	}
	
	void LoadBlobData(CBlob@ blob, const string[]@ data) override
	{
		basicHandler.LoadBlobData(blob, data);
		const bool scyther = data.length > 9 ? parseBool(data[9]) : true;
		blob.set_bool("scyther inside", scyther);
	}
}

class NukeBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		if (blob.exists("nuke_boomtime"))
		{
			data += (blob.get_u32("nuke_boomtime") - getGameTime()) + ";";
		}
		return data;
	}
	
	void LoadBlobData(CBlob@ blob, const string[]@ data) override
	{
		basicHandler.LoadBlobData(blob, data);
		const u32 boomtime = data.length > 9 ? parseInt(data[9]) : 0;
		if (boomtime > 0)
		{
			blob.Tag("nuke_active");
			blob.set_u32("nuke_boomtime", boomtime);
		}
	}
}

class DiscBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		data += blob.get_u8("trackID") + ";";
		return data;
	}
	
	CBlob@ CreateBlob(const string&in name, const Vec2f&in pos, const string[]@ data) override
	{
		const u8 trackID = data.length > 9 ? parseInt(data[9]) : 0;
		CBlob@ blob = server_CreateBlobNoInit(name);
		blob.set_u8("trackID", trackID);
		blob.setPosition(pos);
		blob.Init();
		return blob;
	}
}

class BomberBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		data += blob.get_f32("fly_amount") + ";";
		return data;
	}
	
	void LoadBlobData(CBlob@ blob, const string[]@ data) override
	{
		basicHandler.LoadBlobData(blob, data);
		const f32 fly_amount = data.length > 9 ? parseFloat(data[9]) : 0.0f;
		blob.set_f32("fly_amount", fly_amount);
	}
}

class BotBlobHandler : BlobDataHandler
{
	CBlob@ CreateBlob(const string&in name, const Vec2f&in pos, const string[]@ data) override
	{
		CBlob@ blob = server_CreateBlobNoInit(name);
		blob.setPosition(pos);
		blob.Tag("no_weapon");
		blob.Init();
		return blob;
	}
}

class SignBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		data += blob.get_string("text") + ";";
		return data;
	}
	
	CBlob@ CreateBlob(const string&in name, const Vec2f&in pos, const string[]@ data) override
	{
		const string text = data.length > 9 ? data[9] : "";
		CBlob@ blob = server_CreateBlobNoInit(name);
		blob.set_string("text", text);
		blob.setPosition(pos);
		blob.Init();
		return blob;
	}
}

class PlayerBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);

		string username = "";
		u16 coins = 0;
		CPlayer@ player = blob.getPlayer();
		if (player !is null)
		{
			username = player.getUsername();
			coins = player.getCoins();
		}
		else if (blob.exists("sleeper_name"))
			username = blob.get_string("sleeper_name");

		if (!username.isEmpty())
		{
			data += username + ";";
			data += coins + ";";
		}

		return data;
	}

	void LoadBlobData(CBlob@ blob, const string[]@ data) override
	{
		basicHandler.LoadBlobData(blob, data);
		const string username = data.length > 9 ? data[9] : "";
		const u16 coins = data.length > 10 ? parseInt(data[10]) : 0;
		if (!username.isEmpty())
		{
			blob.set_string("sleeper_name", username);
			blob.set_u16("sleeper_coins", coins);
			blob.Tag("sleeper");
		}
	}
}

class GunBlobHandler : BlobDataHandler
{
	string Serialize(CBlob@ blob) override
	{
		string data = basicHandler.Serialize(blob);
		GunInfo@ gun;
		if (blob.get("gunInfo", @gun))
		{
			data += gun.ammo + ";";
		}
		return data;
	}
	
	void LoadBlobData(CBlob@ blob, const string[]@ data) override
	{
		basicHandler.LoadBlobData(blob, data);
		GunInfo@ gun;
		if (blob.get("gunInfo", @gun))
		{
			const u16 ammo = data.length > 9 ? parseInt(data[9]) : 0;
			gun.ammo = ammo;
		}
	}
}

BlobDataHandler@ getBlobHandler(const string&in name)
{
	BlobDataHandler@ handler;
	if (!blobHandlers.get(name, @handler))
	{
		blobHandlers.get("default", @handler);
	}

	return handler;
}

bool parseBool(const string&in data)
{
	return data == "1";
}
