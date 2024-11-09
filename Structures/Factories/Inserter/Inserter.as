#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	// this.set_TileType("background tile", CMap::tile_castle_back);
	this.getCurrentScript().tickFrequency = 120;
	
	this.Tag("builder always hit");
	this.addCommandID("server_use");
	this.addCommandID("client_use");
	
	this.inventoryButtonPos = Vec2f(0, 16);
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (caller.getDistanceTo(this) > this.getRadius() * 2) return;

	const int icon = !this.isFacingLeft() ? 18 : 17;
	CButton@ button = caller.CreateGenericButton(icon, Vec2f(0, 0), this, this.getCommandID("server_use"), Translate::Flip);
}

void onCommand(CBlob@ this, u8 cmd, CBitStream @params)
{
	if (cmd == this.getCommandID("server_use") && isServer())
	{
		this.SetFacingLeft(!this.isFacingLeft());
		
		CBitStream stream;
		stream.write_bool(this.isFacingLeft());
		this.SendCommand(this.getCommandID("client_use"), stream);
	}
	else if (cmd == this.getCommandID("client_use") && isClient())
	{
		const bool face = params.read_bool();
		this.SetFacingLeft(face);
	}
}

void onTick(CBlob@ this)
{
	const f32 sign = this.isFacingLeft() ? -1 : 1;
	Vec2f side = Vec2f(12 * sign, 0);
	Vec2f position = this.getPosition();
	
	CMap@ map = getMap();
	CBlob@ blob1 = map.getBlobAtPosition(position + side);
	if (blob1 is null) return;
	
	CInventory@ inv1 = blob1.getInventory();
	if (inv1 is null) return;
	
	CBlob@ item = inv1.getItem(0);
	if (item is null) return;
	
	CBlob@ blob2 = map.getBlobAtPosition(position - side);
	if (blob2 is null) return;
	
	CInventory@ inv2 = blob2.getInventory();
	if (inv2 is null) return;
	
	if (!inv2.isFull())
	{
		blob2.server_PutInInventory(item);
		this.getSprite().PlaySound("bridge_open.ogg", 1.00f, 1.00f);
	}
}
