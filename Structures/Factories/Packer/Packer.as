//Packer.as

#include "TC_Translation.as";

const u8 packer_maximum_mode = 36;

void onInit(CBlob@ this)
{
	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	this.Tag("ignore extractor");
	
	this.set_u8("packer mode", 1);
	
	this.addCommandID("server set packer mode");
	
	AddIconToken("$packer_icon_up$", "Packer_Icons.png", Vec2f(16, 16), 0);
	AddIconToken("$packer_icon_down$", "Packer_Icons.png", Vec2f(16, 16), 1);
}

void onTick(CBlob@ this)
{
	CInventory@ inv = this.getInventory();
	if (inv.getItemsCount() == 0) return;
	
	CBlob@[] blobs;
	
	for (uint i = 0; i < inv.getItemsCount(); i++)
	{
		CBlob@ blob = inv.getItem(i);
		if (blob !is null && blob.getQuantity() == blob.maxQuantity)
		{
			blobs.push_back(blob);
		}
	}
	
	if (blobs.length >= this.get_u8("packer mode"))
	{
		PackItems(this);
	}
}

void PackItems(CBlob@ this)
{	
	if (isServer())
	{
		CBlob@ crate = server_CreateBlobNoInit("crate");
		if (crate !is null)
		{
			crate.server_setTeamNum(this.getTeamNum());
			crate.setPosition(this.getPosition());
			crate.Tag("packer crate");
			crate.Init();

			this.getInventory().server_MoveInventoryTo(crate.getInventory());
		}
	}	
	
	if (isClient())
	{
		this.getSprite().PlaySound("BombMake.ogg");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	if (blob.isAttached() || blob.hasTag("player") || blob.getShape().isStatic()) return;

	if (blob.getOldVelocity().Length() >= 8.0f) return; 
	
	if (blob.canBePutInInventory(this))
	{
		this.server_PutInInventory(blob);
		this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return this.getDistanceTo(forBlob) < this.getRadius() * 2;
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!isInventoryAccessible(this, caller)) return;

	CButton@ button = caller.CreateGenericButton(24, Vec2f(0, -8), this, Menu, Translate::SetPacker);
}

void Menu(CBlob@ this, CBlob@ caller)
{	
	PackerMenu(this, caller);
}

void PackerMenu(CBlob@ this, CBlob@ caller, const u8&in packer_mode = 255)
{
	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos(), this, Vec2f(2, 1), Translate::SetPacker);
	if (menu is null) return;
	
	const u8 mode = packer_mode != 255 ? packer_mode : this.get_u8("packer mode");
	{
		const u8 next_mode = Maths::Max(mode - 1, 1);
		const string text = Translate::Decrement.replace("{STACKS}", mode+"");
		
		CBitStream params;
		params.write_netid(this.getNetworkID());
		params.write_netid(caller.getNetworkID());
		params.write_u8(next_mode);
		CGridButton@ butt = menu.AddButton("$packer_icon_down$", text, "Packer.as", "Callback_SetPackerMode", params);
		butt.SetEnabled(mode > 1);
	}
	{
		const u8 next_mode = Maths::Min(mode + 1, packer_maximum_mode);
		const string text = Translate::Increment.replace("{STACKS}", mode+"");
		
		CBitStream params;
		params.write_netid(this.getNetworkID());
		params.write_netid(caller.getNetworkID());
		params.write_u8(next_mode);
		CGridButton@ butt = menu.AddButton("$packer_icon_up$", text, "Packer.as", "Callback_SetPackerMode", params);
		butt.SetEnabled(mode < packer_maximum_mode);
	}
}

void Callback_SetPackerMode(CBitStream@ params)
{
	CBlob@ this = getBlobByNetworkID(params.read_netid());
	if (this is null) return;
	
	CBlob@ caller = getBlobByNetworkID(params.read_netid());
	if (caller is null) return;
	
	const u8 packer_mode = params.read_u8();
	CBitStream stream;
	stream.write_u8(packer_mode);
	this.SendCommand(this.getCommandID("server set packer mode"), stream);
	
	PackerMenu(this, caller, packer_mode);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server set packer mode") && isServer())
	{
		this.set_u8("packer mode", params.read_u8());
		this.Sync("packer mode", true);
	}
}
