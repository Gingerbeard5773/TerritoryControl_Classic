#include "ResearchCommon.as"

string getButtonRequirementsText(CBitStream@ bs, bool missing)
{
	string text, requiredType, name, friendlyName;
	u16 quantity = 0;
	bs.ResetBitIndex();

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, requiredType, name, friendlyName, quantity);
		const string quantityColor = missing ? "$RED$" : "$GREEN$";

		if (requiredType == "blob")
		{
			if (quantity > 0)
			{
				text += quantityColor;
				text += quantity;
				text += quantityColor;
				text += " ";
			}
			text += "$"; text += name; text += "$";
			text += " ";
			text += quantityColor;
			text += getTranslatedString(friendlyName);
			text += quantityColor;
			// text += " required.";
			text += "\n";
		}
		else if (requiredType == "tech" && missing)
		{
			text += " \n$"; text += name; text += "$ ";
			text += quantityColor;
			text += friendlyName;
			text += quantityColor;
			text += "\n\ntechnology required.\n";
		}
		else if (requiredType == "not tech" && missing)
		{
			text += " \n";
			text += quantityColor;
			text += friendlyName;
			text += " technology already acquired.\n";
			text += quantityColor;
		}
		else if (requiredType == "coin")
		{
			text += getTranslatedString("{COINS_QUANTITY} $COIN$ required\n").replace("{COINS_QUANTITY}", "" + quantity);
		}
		else if (requiredType == "hurt")
		{
			text += getTranslatedString("$HEART$ Must be hurt\n");
		}
		else if (requiredType == "no more" && missing)
		{
			text += quantityColor;
			text += "Only " + quantity + " " + friendlyName + " per-team possible. \n";
			text += quantityColor;
		}
		else if (requiredType == "no less" && missing)
		{
			text += quantityColor;
			text += "At least " + quantity + " " + friendlyName + " required. \n";
			text += quantityColor;
		}
	}

	return text;
}

void SetItemDescription(CGridButton@ button, CBlob@ caller, CBitStream &in reqs, const string& in description, CInventory@ anotherInventory = null)
{
	if (button !is null && caller !is null && caller.getInventory() !is null)
	{
		CBitStream missing;
		if (hasRequirements(caller.getInventory(), anotherInventory, reqs, missing))
		{
			button.hoverText = description + "\n\n " + getButtonRequirementsText(reqs, false);
		}
		else
		{
			button.hoverText = description + "\n\n " + getButtonRequirementsText(missing, true);
			button.SetEnabled(false);
		}
	}
}

// read/write

void AddRequirement(CBitStream@ bs, const string &in req, const string &in blobName, const string &in friendlyName, const u16 &in quantity = 1)
{
	bs.write_string(req);
	bs.write_string(blobName);
	bs.write_string(friendlyName);
	bs.write_u16(quantity);
}

void AddHurtRequirement(CBitStream@ bs)
{
	bs.write_string("hurt");
}

bool ReadRequirement(CBitStream@ bs, string &out req, string &out blobName, string &out friendlyName, u16 &out quantity)
{
	if (!bs.saferead_string(req)) return false;

	if (req == "hurt") return true;

	if (!bs.saferead_string(blobName)) return false;

	if (!bs.saferead_string(friendlyName)) return false;

	if (!bs.saferead_u16(quantity)) return false;

	return true;
}

bool hasRequirements(CInventory@ inv1, CInventory@ inv2, CBitStream@ bs, CBitStream@ missingBs, bool &in inventoryOnly = false)
{
	string req, blobName, friendlyName;
	u16 quantity = 0;
	missingBs.Clear();
	bs.ResetBitIndex();
	bool has = true;

	CBlob@ playerBlob = (inv1 !is null ? (inv1.getBlob().getPlayer() !is null ? inv1.getBlob() :
					    (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null)) :
					    (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null));

	CBlob@[] remoteStorages = getAvailableRemoteStorages(playerBlob);

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, req, blobName, friendlyName, quantity);

		if (req == "blob")
		{
			int sum = (inv1 !is null ? inv1.getBlob().getBlobCount(blobName) : 0) + (inv2 !is null ? inv2.getBlob().getBlobCount(blobName) : 0);
			for (int i = 0; i < remoteStorages.length; i++)
			{
				sum += remoteStorages[i].getBlobCount(blobName);
			}
			if (sum < quantity)
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if (req == "coin")
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2 = inv2 !is null ? inv2.getBlob().getPlayer() : null;
			u16 sum = (player1 !is null ? player1.getCoins() : 0) + (player2 !is null ? player2.getCoins() : 0);
			if (sum < quantity)
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}
		else if (req == "hurt")
		{
			CBlob@ blob = inv1 !is null ? inv1.getBlob() : null;
			if (blob is null || blob.getHealth() >= blob.getInitialHealth())
			{
				AddHurtRequirement(missingBs);
				has = false;
			}
		}
		/*else if ((req == "no more" || req == "no less") && inv1 !is null)
		{
			int teamNum = inv1.getBlob().getTeamNum();
			int count = 0;
			CBlob@[] blobs;
			if (getBlobsByName(blobName, @blobs))
			{
				for (uint step = 0; step < blobs.length; ++step)
				{
					CBlob@ blob = blobs[step];
					if (blob.getTeamNum() == teamNum)
					{
						count++;
					}
				}
			}

			if ((req == "no more" && count >= quantity) || (req == "no less" && count < quantity))
			{
				AddRequirement(missingBs, req, blobName, friendlyName, quantity);
				has = false;
			}
		}*/
	}

	missingBs.ResetBitIndex();
	bs.ResetBitIndex();
	return has;
}

bool hasRequirements(CInventory@ inv, CBitStream@ bs, CBitStream@ missingBs, bool &in inventoryOnly = false)
{
	return hasRequirements(inv, null, bs, missingBs, inventoryOnly);
}

void server_TakeRequirements(CInventory@ inv1, CInventory@ inv2, CBitStream@ bs)
{
	if (!isServer()) return;

	CBlob@ playerBlob = (inv1 !is null ? (inv1.getBlob().getPlayer() !is null ? inv1.getBlob() :
					    (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null)) :
					    (inv2 !is null ? (inv2.getBlob().getPlayer() !is null ? inv2.getBlob() : null) : null));
	CBlob@[] remoteStorages = getAvailableRemoteStorages(playerBlob);

	string req, blobName, friendlyName;
	u16 quantity;
	bs.ResetBitIndex();
	while(!bs.isBufferEnd())
	{
		ReadRequirement(bs, req, blobName, friendlyName, quantity);
		if (req == "blob")
		{
			u16 taken = 0;
			if (inv1 !is null)
			{
				CBlob@ blob = inv1.getBlob();
				const u16 take = Maths::Min(blob.getBlobCount(blobName), quantity - taken);
				blob.TakeBlob(blobName, take);
				taken += take;
			}
			if (inv2 !is null && taken < quantity)
			{
				CBlob@ blob = inv2.getBlob();
				const u16 remaining = quantity - taken;
				const u16 take = Maths::Min(blob.getBlobCount(blobName), remaining);
				blob.TakeBlob(blobName, take);
				taken += take;
			}

			for (int i = 0; i < remoteStorages.length; i++)
			{
				if (taken >= quantity) break;

				CBlob@ remoteStorage = remoteStorages[i];
				const u16 remaining = quantity - taken;
				const u16 take = Maths::Min(remoteStorage.getBlobCount(blobName), remaining);
				remoteStorage.TakeBlob(blobName, take);
				taken += take;
			}
		}
		else if (req == "coin")
		{
			CPlayer@ player1 = inv1 !is null ? inv1.getBlob().getPlayer() : null;
			CPlayer@ player2 = inv2 !is null ? inv2.getBlob().getPlayer() : null;
			int taken = 0;
			if (player1 !is null)
			{
				const int take = Maths::Min(player1.getCoins(), quantity);
				player1.server_setCoins(player1.getCoins() - take);
				taken += take;
			}
			if (player2 !is null && taken < quantity)
			{
				const int remaining = quantity - taken;
				const int take = Maths::Min(player2.getCoins(), remaining);
				player2.server_setCoins(player2.getCoins() - take);
				taken += take;
			}
		}
	}

	bs.ResetBitIndex();
}

void server_TakeRequirements(CInventory@ inv, CBitStream@ bs)
{
	server_TakeRequirements(inv, null, bs);
}

CBlob@[] getAvailableRemoteStorages(CBlob@ playerBlob)
{
	CBlob@[] remoteStorages;

	if (playerBlob is null) return remoteStorages;

	const int playerTeam = playerBlob.getTeamNum();
	if (playerTeam >= getRules().getTeamsCount()) return remoteStorages;

	getBlobsByTag("remote storage", @remoteStorages);

	Vec2f playerPosition = playerBlob.getPosition();
	bool canAccessRemoteStorage = false;
	for (int i = 0; i < remoteStorages.length; i++)
	{
		CBlob@ storage = remoteStorages[i];
		if (storage.getTeamNum() != playerTeam)
		{
			remoteStorages.erase(i);
			i--;
		}
		else if ((storage.getPosition() - playerPosition).Length() < 250.0f && storage.hasTag("remote access"))
		{
			canAccessRemoteStorage = true;
		}
	}

	if (!canAccessRemoteStorage)
	{
		remoteStorages.clear();
	}
	
	return remoteStorages;
}
