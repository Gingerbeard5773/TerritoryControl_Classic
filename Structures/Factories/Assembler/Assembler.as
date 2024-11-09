#include "Requirements.as";
#include "TC_Translation.as";

void onInit(CSprite@ this)
{
	this.SetEmitSound("assembler_loop.ogg");
	this.SetEmitSoundVolume(1.0f);
	this.SetEmitSoundSpeed(0.5f);
	this.SetEmitSoundPaused(false);

	{
		CSpriteLayer@ gear = this.addSpriteLayer("gear1", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(-10.0f, -4.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
		}
	}

	{
		CSpriteLayer@ gear = this.addSpriteLayer("gear2", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(17.0f, -10.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
		}
	}

	{
		CSpriteLayer@ gear = this.addSpriteLayer("gear3", "Assembler.png" , 16, 16, this.getBlob().getTeamNum(), this.getBlob().getSkinNum());
		if (gear !is null)
		{
			Animation@ anim = gear.addAnimation("default", 0, false);
			anim.AddFrame(3);
			gear.SetOffset(Vec2f(6.0f, -4.0f));
			gear.SetAnimation("default");
			gear.SetRelativeZ(-60);
			gear.RotateBy(-22, Vec2f(0.0f,0.0f));
		}
	}
}

void onTick(CSprite@ this)
{
	if (this.getSpriteLayer("gear1") !is null)
	{
		this.getSpriteLayer("gear1").RotateBy(5, Vec2f(0.0f, 0.0f));
	}
	if (this.getSpriteLayer("gear2") !is null)
	{
		this.getSpriteLayer("gear2").RotateBy(-5, Vec2f(0.0f, 0.0f));
	}
	if (this.getSpriteLayer("gear3") !is null)
	{
		this.getSpriteLayer("gear3").RotateBy(5, Vec2f(0.0f, 0.0f));
	}
}

class AssemblerItem
{
	string resultname;
	u32 resultcount;
	string title;
	CBitStream reqs;

	AssemblerItem(string resultname, u32 resultcount, string title)
	{
		this.resultname = resultname;
		this.resultcount = resultcount;
		this.title = title;
	}
}

void onInit(CBlob@ this)
{
	AssemblerItem[] items;
	{
		AssemblerItem i("mat_pistolammo", 50, name(Translate::LowCalAmmo)+" (50)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(i.reqs, "blob", "mat_copperingot", name(Translate::CopperIngot), 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 50);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_rifleammo", 15, name(Translate::HighCalAmmo)+" (15)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 1);
		AddRequirement(i.reqs, "blob", "mat_copperingot", name(Translate::CopperIngot), 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 15);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_gatlingammo", 50, name(Translate::MachinegunAmmo)+" (50)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 1);
		AddRequirement(i.reqs, "blob", "mat_copperingot", name(Translate::CopperIngot), 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 50);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_shotgunammo", 10, name(Translate::ShotgunAmmo)+" (10)");
		AddRequirement(i.reqs, "blob", "mat_copperingot", name(Translate::CopperIngot), 1);
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 10);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_tankshell", 4, name(Translate::TankShell)+" (4)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_howitzershell", 2, name(Translate::HowitzerShell)+" (2)");
		AddRequirement(i.reqs, "blob", "mat_copperingot", name(Translate::CopperIngot), 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 30);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_smallbomb", 4, name(Translate::SmallBomb)+" (4)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_incendiarybomb", 4, name(Translate::IncendiaryBomb)+" (4)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(i.reqs, "blob", "mat_oil", Translate::Oil, 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("revolver", 1, name(Translate::Revolver)+" (1)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(i.reqs, "blob", "mat_steelingot", name(Translate::SteelIngot), 1);
		items.push_back(i);
	}
	{
		AssemblerItem i("rifle", 1, name(Translate::Rifle)+" (1)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 60);
		AddRequirement(i.reqs, "blob", "mat_steelingot", name(Translate::SteelIngot), 1);
		items.push_back(i);
	}
	{
		AssemblerItem i("mat_smallrocket", 4, name(Translate::SmallRocket)+" (4)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 40);
		AddRequirement(i.reqs, "blob", "mat_coal", Translate::Coal, 4);
		items.push_back(i);
	}
	{
		AssemblerItem i("rocket", 1, name(Translate::Rocket)+" (1)");
		AddRequirement(i.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 50);
		items.push_back(i);
	}
	{
		AssemblerItem i("foodcan", 2, name(Translate::ScrubChow)+" (2)");
		AddRequirement(i.reqs, "blob", "mat_meat", Translate::Meat, 40);
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 1);
		items.push_back(i);
	}	
	{
		AssemblerItem i("bigfoodcan", 1, name(Translate::ScrubChowXL)+" (1)");
		AddRequirement(i.reqs, "blob", "mat_meat", Translate::Meat, 80);
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 5);
		items.push_back(i);
	}
	{
		AssemblerItem i("mine", 2, getTranslatedString("Mine")+" (2)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 1);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 20);
		items.push_back(i);
	}
	{
		AssemblerItem i("fragmine", 1, name(Translate::Fragmine)+" (1)");
		AddRequirement(i.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		AddRequirement(i.reqs, "blob", "mat_sulphur", Translate::Sulphur, 20);
		items.push_back(i);
	}
	this.set("items", items);

	this.set_TileType("background tile", CMap::tile_castle_back);

	this.getCurrentScript().tickFrequency = 60;

	this.Tag("builder always hit");
	this.Tag("ignore extractor");

	this.addCommandID("server set crafting");
	this.addCommandID("sv_store");

	this.set_u8("crafting", 0);
	
	for (uint i = 0; i < items.length; i += 1)
	{
		AddIconToken("$assembler_icon" + i + "$", "AssemblerIcons.png", Vec2f(16, 16), i);
	}
}

void GetButtonsFor(CBlob@ this, CBlob@ caller)
{
	if (!isInventoryAccessible(this, caller)) return;

	CButton@ button = caller.CreateGenericButton(15, Vec2f(0,-8), this, Menu, Translate::SetAssembler);
	
	CInventory@ inv = caller.getInventory();
	if (inv is null) return;
	
	const u8 crafting = this.get_u8("crafting");
	AssemblerItem[] items = getItems(this);
	if (crafting >= items.length) return;
	
	AssemblerItem item = items[crafting];
	
	CBitStream bs = item.reqs;
	bs.ResetBitIndex();
	string name;

	while (!bs.isBufferEnd())
	{
		string unused = "";
		ReadRequirement(bs, unused, name, unused, 0);

		if (inv.getItem(name) !is null)
		{
			CButton@ store = caller.CreateGenericButton(28, Vec2f(0, 6), this, this.getCommandID("sv_store"), "Store");
			break;
		}
	}
}

void Menu(CBlob@ this, CBlob@ caller)
{
	if (!caller.isMyPlayer()) return;

	CGridMenu@ menu = CreateGridMenu(getDriver().getScreenCenterPos() + Vec2f(0.0f, 0.0f), this, Vec2f(4, 4), Translate::SetAssembler);
	if (menu is null) return;

	AssemblerItem[] items = getItems(this);
	for (uint i = 0; i < items.length; i += 1)
	{
		AssemblerItem item = items[i];

		CBitStream pack;
		pack.write_u8(i);
		
		const bool assembling = this.get_u8("crafting") == i;

		string text = Translate::SetAssembler+": " + item.title;
		if (assembling)
			text = Translate::AlreadySet+": " + item.title;

		CGridButton@ butt = menu.AddButton("$assembler_icon" + i + "$", text, this.getCommandID("server set crafting"), pack);
		butt.hoverText = item.title + "\n" + getButtonRequirementsText(item.reqs, false);
		butt.SetEnabled(!assembling);
	}
}

void onCommand(CBlob@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("server set crafting") && isServer())
	{
		this.set_u8("crafting", params.read_u8());
		this.Sync("crafting", true);
	}
	else if (cmd == this.getCommandID("sv_store") && isServer())
	{
		CPlayer@ player = getNet().getActiveCommandPlayer();
		if (player is null) return;

		CBlob@ caller = player.getBlob();
		if (caller is null) return;

		CBlob@ carried = caller.getCarriedBlob();
		if (carried !is null && carried.hasTag("temp blob"))
		{
			carried.server_Die();
		}

		CInventory@ inv = caller.getInventory();
		if (inv is null) return;

		const u8 crafting = this.get_u8("crafting");
		AssemblerItem[] items = getItems(this);
		if (crafting >= items.length) return;

		AssemblerItem item = items[crafting];
		for (int i = 0; i < inv.getItemsCount(); i++)
		{
			CBlob@ blob = inv.getItem(i);

			CBitStream bs = item.reqs;
			bs.ResetBitIndex();
			string name;

			while (!bs.isBufferEnd())
			{
				string unused = "";
				ReadRequirement(bs, unused, name, unused, 0);

				if (blob.getName() == name)
				{
					caller.server_PutOutInventory(blob);
					this.server_PutInInventory(blob);
					i--;
					break;
				}
			}
		}
	}
}

void onTick(CBlob@ this)
{
	const int crafting = this.get_u8("crafting");
	AssemblerItem[] items = getItems(this);
	if (crafting >= items.length) return;

	AssemblerItem item = items[crafting];
	CInventory@ inv = this.getInventory();

	CBitStream missing;
	if (hasRequirements(inv, item.reqs, missing))
	{
		if (isServer())
		{
			CBlob@ mat = server_CreateBlobNoInit(item.resultname);
			mat.server_setTeamNum(this.getTeamNum());
			mat.setPosition(this.getPosition());
			mat.Tag("custom quantity");
			mat.server_SetQuantity(item.resultcount);
			mat.Init();

			server_TakeRequirements(inv, item.reqs);
		}

		this.getSprite().PlaySound("ProduceSound.ogg");
		this.getSprite().PlaySound("BombMake.ogg");
	}
}

void onCollision(CBlob@ this, CBlob@ blob, bool solid)
{
	if (blob is null) return;

	const int crafting = this.get_u8("crafting");
	AssemblerItem[] items = getItems(this);
	if (crafting >= items.length) return;

	AssemblerItem item = items[crafting];

	bool isMat = false;
	CBitStream bs = item.reqs;
	bs.ResetBitIndex();
	string text, requiredType, name, friendlyName;
	u16 quantity = 0;

	while (!bs.isBufferEnd())
	{
		ReadRequirement(bs, requiredType, name, friendlyName, quantity);

		if (blob.getName() == name)
		{
			isMat = true;
			break;
		}
	}

	if (isMat && !blob.isAttached() && blob.hasTag("material"))
	{
		if (isServer()) this.server_PutInInventory(blob);
		if (isClient()) this.getSprite().PlaySound("bridge_open.ogg");
	}
}

bool isInventoryAccessible(CBlob@ this, CBlob@ forBlob)
{
	return ((forBlob.getTeamNum() == this.getTeamNum() || this.getTeamNum() >= getRules().getTeamsCount()) && forBlob.isOverlapping(this));
}

AssemblerItem[] getItems(CBlob@ this)
{
	AssemblerItem[] items;
	this.get("items", items);
	return items;
}
