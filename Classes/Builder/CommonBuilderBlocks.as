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
#include "CustomTiles.as";

const string blocks_property = "blocks";
const string inventory_offset = "inventory offset";

void addCommonBuilderBlocks(BuildBlock[][]@ blocks, int team_num = 0, const string&in gamemode_override = "")
{
	BuildBlock[] page_0;
	blocks.push_back(page_0);
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
		BuildBlock b(CMap::tile_wood, "wood_block", "$wood_block$", "Wood Block\nCheap block\nwatch out for fire!");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_wood_back, "back_wood_block", "$back_wood_block$", "Back Wood Wall\nCheap extra support");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_door", "$stone_door$", "Stone Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_door", "$wooden_door$", "Wooden Door\nPlace next to walls");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "ladder", "$ladder$", "Ladder\nAnyone can climb it");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wooden_platform", "$wooden_platform$", "Wooden Platform\nOne way platform");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "spikes", "$spikes$", "Spikes\nPlace on Stone Block\nfor Retracting Trap");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "trap_block", "$trap_block$", "Trap Block\nOnly enemies can pass");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_door", "$iron_door$", "Iron Door\nDoesn't have to be placed next to walls!");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 4);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wood_triangle", "$wood_triangle$", "Wooden Triangle");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_triangle", "$stone_triangle$", "Stone Triangle");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_iron, "iron_block", "$iron_block$", "Iron Plating\nA durable metal block. Indestructible by peasants.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_halfblock", "$stone_halfblock$", "Stone Half Block");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_plasteel, "plasteel_block", "$plasteel_block$", "Plasteel Panel\nA highly advanced composite material. Nearly indestructible.");
		AddRequirement(b.reqs, "blob", "mat_plasteel", "Plasteel Sheet", 4);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_platform", "$iron_platform$", "Iron Platform\nReinforced one-way platform. Indestructible by peasants.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 3);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ground, "ground_block", "$ground_block$", "Dirt\nFairly resistant to explosions.\nMay be only placed on dirt backgrounds or damaged dirt.");
		AddRequirement(b.reqs, "blob", "mat_dirt", "Dirt", 15);
		blocks[0].push_back(b);
	}
	// {
		// BuildBlock b(CMap::tile_brick_v0, "brick_block", "$brick_block$", "Bricks\nA cheap but durable wall.");
		// // AddRequirement(b.reqs, "blob", "mat_plasteel", "Plasteel Sheet", 4);
		// blocks[0].push_back(b);
	// }
	// {
		// BuildBlock b(CMap::tile_glass, "glass_block", "$glass_block$", "Glass\nFancy and fragile.");
		// // AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 2);
		// blocks[0].push_back(b);
	// }
	
	
	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "quarters", "$icon_quarters$", "Quarters\n" + Descriptions::quarters);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "buildershop", "$icon_buildershop$", "Builder Workshop\n" + Descriptions::buildershop);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "tinkertable", "$icon_tinkertable$", "Mechanist's Workshop\nA place where you can construct various trinkets and advanced machinery. Repairs adjacent vehicles.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 70);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "armory", "$icon_armory$", "Armory\nA workshop where you can craft cheap equipment. Automatically stores nearby dropped weapons and ammunition.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "gunsmith", "$icon_gunsmith$", "Gunsmith's Workshop\nA workshop for those who enjoy making holes. Slowly produces bullets.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "bombshop", "$icon_bombshop$", "Demolitionist's Workshop\nFor those with an explosive personality.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "forge", "$icon_forge$", "Forge\nEnables you to process raw metals into pure ingots and alloys.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 70);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "construction_yard", "$icon_constructionyard$", "Construction Yard\nUsed to construct various vehicles.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(64, 56);
		blocks[1].push_back(b);

	}
	{
		BuildBlock b(0, "storage", "$icon_storage$", "Storage\nA storage than can hold materials and items.\nCan be only accessed by the owner team.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "camp", "$icon_camp$", "Camp\nA basic faction base. Can be upgraded to gain\nspecial functions and more durability.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 350);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		AddRequirement(b.reqs, "coin", "", "Coins", 100);
		
		b.buildOnGround = true;
		b.size.Set(80, 24);
		blocks[1].push_back(b);
	}

	
	BuildBlock[] page_2;
	blocks.push_back(page_2);
	{
		BuildBlock b(0, "conveyor", "$icon_conveyor$", "Conveyor Belt\nUsed to transport items.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 4);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 6);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "seperator", "$icon_separator$", "Separator\nItems matching the filter will be launched away.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "launcher", "$icon_launcher$", "Launcher\nLaunches items to the eternity and beyond.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "filter", "$icon_filter$", "Filter\nItems matching the filter won't collide with this.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "autoforge", "$icon_autoforge$", "Auto-Forge\nProcesses raw materials and alloys just for you.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "assembler", "$icon_assembler$", "Assembler\nAn elaborate piece of machinery that manufactures items.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "drillrig", "$icon_drillrig$", "Driller Mole\nAn automatic drilling machine that mines resources underneath.");
		AddRequirement(b.reqs, "blob", "drill", "Drill", 1);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 2);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "hopper", "$icon_hopper$", "Hopper\nPicks up items lying on the ground.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "extractor", "$icon_extractor$", "Extractor\nGrabs items from nearby inventories.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		b.buildOnGround = true;
		b.size.Set(16, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "industriallamp", "$icon_industriallamp$", "Industrial Lamp\nA sturdy lamp to ligthen up the mood in your factory.\nActs as a support block.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 30);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "grinder", "$icon_grinder$", "Grinder\nA dangerous machine capable of destroying almost everything.");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 5);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "packer", "$icon_packer$", "Packer\nA safe machine capable of packing almost everything.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		b.buildOnGround = true;
		b.size.Set(24, 16);
		blocks[2].push_back(b);
	}
	{ //newer gen tc import
		BuildBlock b(0, "inserter", "$icon_inserter$", "Inserter\nTransfers items between inventories next to it.\nLarge funnel acts as input, small funnel as output.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[2].push_back(b);
	}

	BuildBlock[] page_3;
	blocks.push_back(page_3);
	{
		BuildBlock b(0, "woodchest", "$icon_chest$", "Wooden Chest\nA regular wooden chest used for storage.\nCan be accessed by anyone.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "ironlocker", "$icon_ironlocker$", "Personal Locker\nA more secure way to store your items.\nCan be only accessed by the first person to claim it.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingots", 5);
		// AddRequirement(b.reqs, "blob", "mat_steelingot", "Steel Ingot", 1);
		b.buildOnGround = true;
		b.size.Set(16, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "siren", "$icon_siren$", "Air Raid Siren\nWarns of incoming enemy aerial vehicles within 75 block radius.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		AddRequirement(b.reqs, "blob", "mat_goldingot", "Gold Ingot", 2);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "lamppost", "$icon_lamppost$", "Lamp Post\nA fancy light.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		b.buildOnGround = true;
		b.size.Set(8, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "barbedwire", "$icon_barbedwire$", "Barbed Wire\nHurts anyone who passes through it. Good at preventing people from climbing over walls.");
		AddRequirement(b.reqs, "blob", "mat_ironingot", "Iron Ingot", 1);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "teamlamp", "$icon_teamlamp$", "Team Lamp\nGlows with your team's spirit.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		AddRequirement(b.reqs, "blob", "mat_copperwire", "Copper Wire", 1);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "textsign", "$icon_textsign$", "Sign Board\nType '!write -text-' in chat and then use it on the sign. Writing on a paper costs 50 coins.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		
		b.buildOnGround = true;
		b.size.Set(64, 16);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "stonepile", "$icon_stonepile$", "Stone Silo\nAutomatically collects ores from all of your team's mines.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		b.buildOnGround = true;
		b.size.Set(24, 40);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "oiltank", "$icon_oiltank$", "Oil Tank\nAutomatically collects oil from all of your team's pumpjacks.");
		AddRequirement(b.reqs, "blob", "mat_wood","Wood", 250);
		AddRequirement(b.reqs, "blob", "mat_ironingot","Iron Ingots", 2);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		blocks[3].push_back(b);
	}
	//newer gen tc import. thats why its disabled. may enable this if people are ok with it.
	/*{
		BuildBlock b(0, "smallsign", "$icon_smallsign$", "Sign\nType '!write -text-' in chat and then use it on the sign. Writing on a paper costs 50 coins.");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[3].push_back(b);
	}*/
}

ConfigFile@ openBlockBindingsConfig()
{
	ConfigFile cfg = ConfigFile();
	if (!cfg.loadFile("../Cache/BlockBindings.cfg"))
	{
		// write EmoteBinding.cfg to Cache
		cfg.saveFile("BlockBindings.cfg");

	}

	return cfg;
}

u8 read_block(ConfigFile@ cfg, string name, u8 default_value)
{
	u8 read_val = cfg.read_u8(name, default_value);
	return read_val;
}
