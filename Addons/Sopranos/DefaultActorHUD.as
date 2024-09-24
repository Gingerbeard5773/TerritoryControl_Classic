//default actor hud

//Gingerbeard rewrote this script to be MUCH more optimized. Looks a bit different from the OG but imo is cleaner and doesnt bloat the hud as much. fuq u merser

void onInit(CSprite@ this)
{
	this.getCurrentScript().runFlags |= Script::tick_myplayer;
	this.getCurrentScript().tickFrequency = 15;
	this.getCurrentScript().removeIfTag = "dead";
}

void RenderHPBar(CBlob@ blob)
{
	const string heartFile = "GUI/HPbar.png";
	Vec2f origin(52, 10);
	
	int segmentWidth = 24; //32
	GUI::DrawIcon("GUI/jends2.png", 0, Vec2f(8, 16), origin + Vec2f(-8, 0));
	int HPs = 0;
	for (f32 step = 0.0f; step < blob.getInitialHealth(); step += 0.5f)
	{
		GUI::DrawIcon("GUI/HPback.png", 0, Vec2f(12, 16), origin + Vec2f(segmentWidth * HPs, 0)); 
		const f32 thisHP = blob.getHealth() - step;
		if (thisHP > 0)
		{
			Vec2f heartpos = origin + Vec2f(segmentWidth * HPs - 1,0);
			if (thisHP <= 0.125f)        GUI::DrawIcon(heartFile, 4, Vec2f(16,16), heartpos);
			else if (thisHP <= 0.25f)    GUI::DrawIcon(heartFile, 3, Vec2f(16,16), heartpos);
			else if (thisHP <= 0.375f)   GUI::DrawIcon(heartFile, 2, Vec2f(16,16), heartpos);
			else if (thisHP > 0.375f)    GUI::DrawIcon(heartFile, 1, Vec2f(16,16), heartpos);
			else                         GUI::DrawIcon(heartFile, 0, Vec2f(16,16), heartpos);
		}
		HPs++;
	}
	GUI::DrawIcon("GUI/jends2.png", 1, Vec2f(8, 16), origin + Vec2f(segmentWidth * HPs,0));
}

void onRender(CSprite@ this)
{
	if (g_videorecording) return;

    CBlob@ blob = this.getBlob();
	
    RenderHPBar(blob);
	RenderTeamInventoryHUD(blob, teamMaterialsQuantity, teamMaterialsReference);
	
	GUI::DrawIcon("GUI/jslot.png", 1, Vec2f(32, 32), Vec2f(2, 2));
}

const string[] teamIngots =
{
	"mat_ironingot",
	"mat_steelingot",
	"mat_copperingot",
	"mat_goldingot",
	"mat_mithrilingot"
};

const string[] teamMaterials = 
{
	"mat_wood",
	"mat_stone",
	
	"mat_ironingot",
	"mat_steelingot",
	"mat_copperingot",
	"mat_goldingot",
	"mat_mithrilingot",
	"mat_iron",
	"mat_coal",
	"mat_copper",
	"mat_gold",
	"mat_mithril",

	"mat_copperwire"
};

bool canAccessRemoteStorage = false;

u16[] teamMaterialsQuantity(teamMaterials.length);
u16[] teamMaterialsReference(teamMaterials.length);

void onTick(CSprite@ this)
{
	GatherTeamMaterials(this.getBlob());
}

void GatherTeamMaterials(CBlob@ blob)
{
	const int playerTeam = blob.getTeamNum();
	if (playerTeam >= getRules().getTeamsCount()) return;
	
	canAccessRemoteStorage = false;

	teamMaterialsQuantity.clear();
	teamMaterialsReference.clear();
	teamMaterialsQuantity.set_length(teamMaterials.length);
	teamMaterialsReference.set_length(teamMaterials.length);

	Vec2f position = blob.getPosition();

	CBlob@[] storages;
	getBlobsByTag("remote storage", @storages);
	
	for (int i = 0; i < storages.length; i++) 
	{
		CBlob@ storage = storages[i];
		if (storage.getTeamNum() != playerTeam) continue;
		
		if ((storage.getPosition() - position).Length() < 250.0f && storage.hasTag("remote access"))
			canAccessRemoteStorage = true;

		CInventory@ inv = storage.getInventory();
		if (inv is null) continue;

		for (int q = 0; q < inv.getItemsCount(); q++)
		{
			CBlob@ item = inv.getItem(q);
			const int index = teamMaterials.find(item.getName());
			if (index != -1)
			{
				teamMaterialsQuantity[index] += item.getQuantity();
				teamMaterialsReference[index] = item.getNetworkID();
			}
		}
	}
}

void RenderTeamInventoryHUD(CBlob@ this, u16[] materialsQuantity, u16[] materialsReference)
{
	const int playerTeam = this.getTeamNum();
	if (playerTeam >= getRules().getTeamsCount()) return;
	
	Vec2f hudPos = Vec2f(0, 0);
	const u32 screenwidth = getScreenWidth();

	GUI::DrawIcon("GUI/jslot.png", 0,					 Vec2f(32, 32), Vec2f(screenwidth - 54, 8) + hudPos);
	GUI::DrawIcon("Emblems.png", playerTeam,			 Vec2f(32, 32), Vec2f(screenwidth - 62, 0) + hudPos);
	GUI::DrawIcon("GUI/jslot.png", 0,					 Vec2f(32, 32), Vec2f(screenwidth - 102, 8) + hudPos);
	GUI::DrawIcon("MenuItems.png", canAccessRemoteStorage ? 28 : 29, Vec2f(32, 32), Vec2f(screenwidth - 110, 0) + hudPos);
	GUI::SetFont("menu");
	GUI::DrawText("Remote access -", Vec2f(screenwidth - 220, 22) + hudPos, canAccessRemoteStorage ? SColor(255, 0, 255, 0) : SColor(255, 255, 0, 0));
	
	u8 j = 0;
	for (u8 i = 0; i < teamMaterials.length; i++) 
	{
		Vec2f materialPos = Vec2f(screenwidth - 54, 54 + j * 46) + hudPos;
		if (!DrawMaterialSlot(this, i, materialPos, materialsQuantity, materialsReference))
			continue;
		
		CBlob@ item = getBlobByNetworkID(materialsReference[i]);
		if (item is null) continue;

		const int ingotindex = teamIngots.find(item.getName());
		if (ingotindex != -1)
		{
			const int oreindex = i + teamIngots.length; //ok i understand that this is pretty hacky. but it works great
			Vec2f orePos = Vec2f(screenwidth - 102, 54 + j * 46) + hudPos;
			
			if (DrawMaterialSlot(this, oreindex, orePos, materialsQuantity, materialsReference))
				materialsQuantity[oreindex] = 0; //dont repeat rendering
		}

		j++;
	}
}

bool DrawMaterialSlot(CBlob@ blob, const u8&in index, Vec2f materialPos, u16[]@ materialsQuantity, u16[]@ materialsReference)
{
	const u16 quantity = materialsQuantity[index];
	if (quantity <= 0) return false;

	CBlob@ item = getBlobByNetworkID(materialsReference[index]);
	if (item is null)
	{
		GatherTeamMaterials(blob); //grab new reference so we dont have a rendering gap
		materialsReference[index] = teamMaterialsReference[index];

		@item = getBlobByNetworkID(materialsReference[index]);
		if (item is null) return false;
	}

	const string name = teamMaterials[index];
	const f32 ratio = f32(quantity) / f32(item.maxQuantity);
	const int textwidth = int(("" + quantity).get_length());

	const u8 iconFrame = (item.getSprite().animation.getFramesCount() - 1) * Maths::Min(quantity, item.maxQuantity) / item.maxQuantity;

	GUI::DrawIcon("GUI/jslot.png", 0, Vec2f(32, 32), materialPos);

	if (name == "mat_stone")     GUI::DrawIcon("GUI/jitem.png", 1, Vec2f(16, 16), materialPos + Vec2f(6, 6), 1.0f);
	else if (name == "mat_wood") GUI::DrawIcon("GUI/jitem.png", 2, Vec2f(16, 16), materialPos + Vec2f(6, 6), 1.0f);
	else                         GUI::DrawIcon(item.inventoryIconName, iconFrame, item.inventoryFrameDimension, materialPos + Vec2f(8, 8));

	GUI::DrawText("" + quantity, materialPos + Vec2f(38 - (textwidth * 8), 26), getRatioColor(ratio));

	return true;
}

SColor getRatioColor(const f32&in ratio)
{
	if (ratio > 0.4f) return SColor(255, 255, 255, 255);
	if (ratio > 0.2f) return SColor(255, 255, 255, 128);
	if (ratio > 0.1f) return SColor(255, 255, 128, 0);

	return SColor(255, 255, 0, 0);
}
