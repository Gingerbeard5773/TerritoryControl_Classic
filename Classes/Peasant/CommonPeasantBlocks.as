// CommonBuilderBlocks.as

//////////////////////////////////////
// Builder menu documentation
//////////////////////////////////////

// To add a new page;

// 1) initialize a new BuildBlock array, 
// example:
// BuildBlock[] my_page;
// blocks.push_back(my_page);

// 2) 
// Add a new string to PAGE_NAME in 
// BuilderInventory.as
// this will be what you see in the caption
// box below the menu

// 3)
// Extend BuilderPageIcons.png with your new
// page icon, do note, frame index is the same
// as array index

// To add new blocks to a page, push_back
// in the desired order to the desired page
// example:
// BuildBlock b(0, "name", "icon", "description");
// blocks[3].push_back(b);

#include "BuildBlock.as";
#include "Requirements.as";
#include "Descriptions.as";
#include "TC_Translation.as";
//#include "CustomTiles.as";

//const string blocks_property = "blocks";
//const string inventory_offset = "inventory offset";

void addCommonPeasantBlocks(BuildBlock[][]@ blocks, int team_num = 0, const string&in gamemode_override = "")
{
	BuildBlock[] page_0;
	blocks.push_back(page_0);
	{
		BuildBlock b(0, "camp", "$icon_faction$", Translate::Faction);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);

		b.buildOnGround = true;
		b.size.Set(80, 24);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wood_triangle", "$wood_triangle$", Translate::WoodTriangle);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle, "stone_block", "$stone_block$", "Stone Block\nBasic building block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_castle_back, "back_stone_block", "$back_stone_block$", "Back Stone Wall\nExtra support");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_triangle", "$stone_triangle$", Translate::StoneTriangle);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_halfblock", "$stone_halfblock$", Translate::HalfBlock);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$wooden_door$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "banditshack", "$icon_banditshack$", Translate::BanditShack);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "tavern", "$tavern$", Translate::Tavern);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 350);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		b.buildOnGround = true;
		b.size.Set(56, 32);
		blocks[0].push_back(b);
	}
	{	///Report fil, he stole my fireplace // Truly ~Fil
		BuildBlock b(0, "fireplace", "$fireplace$", Translate::Campfire);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[0].push_back(b);
	}
	
	BuildBlock[] page_1;
	blocks.push_back(page_1);
	
	BuildBlock[] page_2;
	blocks.push_back(page_2);
}
