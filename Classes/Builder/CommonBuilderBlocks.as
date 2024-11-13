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
#include "TC_Translation.as";

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
		BuildBlock b(0, "iron_door", "$iron_door$", Translate::IronDoor);
		AddRequirement(b.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 4);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "wood_triangle", "$wood_triangle$", Translate::WoodTriangle);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_triangle", "$stone_triangle$", Translate::StoneTriangle);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_iron, "iron_block", "$iron_block$", Translate::IronBlock);
		AddRequirement(b.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "stone_halfblock", "$stone_halfblock$", Translate::HalfBlock);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 5);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_plasteel, "plasteel_block", "$plasteel_block$", Translate::PlasteelBlock);
		AddRequirement(b.reqs, "blob", "mat_plasteel", name(Translate::Plasteel), 4);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(0, "iron_platform", "$iron_platform$", Translate::IronPlatform);
		AddRequirement(b.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 3);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_ground, "ground_block", "$ground_block$", Translate::DirtBlock);
		AddRequirement(b.reqs, "blob", "mat_dirt", Translate::Dirt, 15);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_glass, "glass_block", "$glass_block$", Translate::Glass);
		AddRequirement(b.reqs, "coin", "", "Coin", 10);
		blocks[0].push_back(b);
	}
	{
		BuildBlock b(CMap::tile_glass_back, "glass_block_back", "$glass_block_back$", Translate::GlassBack);
		AddRequirement(b.reqs, "coin", "", "Coin", 5);
		blocks[0].push_back(b);
	}
	
	
	BuildBlock[] page_1;
	blocks.push_back(page_1);
	{
		BuildBlock b(0, "quarters", "$icon_quarters$", getTranslatedString("Quarters") +"\n"+ Descriptions::quarters);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "buildershop", "$icon_buildershop$", getTranslatedString("Builder Shop") +"\n"+ Descriptions::buildershop);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "tinkertable", "$icon_tinkertable$", Translate::Mechanist);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 70);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "armory", "$icon_armory$", Translate::Armory);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "gunsmith", "$icon_gunsmith$", Translate::Gunsmith);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "bombshop", "$icon_bombshop$", Translate::Bombshop);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 100);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 250);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "forge", "$icon_forge$", Translate::Forge);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 150);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 70);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "construction_yard", "$icon_constructionyard$", Translate::Yard);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(64, 56);
		blocks[1].push_back(b);

	}
	{
		BuildBlock b(0, "storage", "$icon_storage$", getTranslatedString("Storage Cache")+"\n"+Descriptions::storagecache);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[1].push_back(b);
	}
	{
		BuildBlock b(0, "camp", "$icon_camp$", Translate::Camp);
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
		BuildBlock b(0, "conveyor", "$icon_conveyor$", Translate::Conveyor);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 4);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 6);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "seperator", "$icon_separator$", Translate::Seperator);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "launcher", "$icon_launcher$", Translate::Launcher);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "filter", "$icon_filter$", Translate::Filter);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "autoforge", "$icon_autoforge$", Translate::AutoForge);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 200);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "assembler", "$icon_assembler$", Translate::Assembler);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 200);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "drillrig", "$icon_drillrig$", Translate::DrillRig);
		AddRequirement(b.reqs, "blob", "drill", "Drill", 1);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		b.buildOnGround = true;
		b.size.Set(24, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "hopper", "$icon_hopper$", Translate::Hopper);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 50);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "extractor", "$icon_extractor$", Translate::Extractor);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		b.buildOnGround = true;
		b.size.Set(16, 32);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "industriallamp", "$icon_industriallamp$", Translate::Lamp);
		AddRequirement(b.reqs, "blob", "mat_stone", "Wood", 30);
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "grinder", "$icon_grinder$", Translate::Grinder);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 250);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		AddRequirement(b.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 5);
		b.buildOnGround = true;
		b.size.Set(40, 24);
		blocks[2].push_back(b);
	}
	{
		BuildBlock b(0, "packer", "$icon_packer$", Translate::Packer);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 50);
		b.buildOnGround = true;
		b.size.Set(24, 16);
		blocks[2].push_back(b);
	}
	{ //newer gen tc import
		BuildBlock b(0, "inserter", "$icon_inserter$", Translate::Inserter);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 25);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[2].push_back(b);
	}

	BuildBlock[] page_3;
	blocks.push_back(page_3);
	{
		BuildBlock b(0, "woodchest", "$icon_chest$", Translate::WoodChest);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "ironlocker", "$icon_ironlocker$", Translate::Locker);
		AddRequirement(b.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 5);
		b.buildOnGround = true;
		b.size.Set(16, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "siren", "$icon_siren$", Translate::Siren);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		AddRequirement(b.reqs, "blob", "mat_goldingot", name(Translate::GoldIngot), 2);
		b.buildOnGround = true;
		b.size.Set(24, 32);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "lamppost", "$icon_lamppost$", Translate::LampPost);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 40);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 25);
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		b.buildOnGround = true;
		b.size.Set(8, 24);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "barbedwire", "$icon_barbedwire$", Translate::BarbedWire);
		AddRequirement(b.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 1);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "teamlamp", "$icon_teamlamp$", Translate::TeamLamp);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "textsign", "$icon_textsign$", Translate::SignBoard);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 150);
		
		b.buildOnGround = true;
		b.size.Set(64, 16);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "stonepile", "$icon_stonepile$", Translate::StoneSilo);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 300);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 75);
		b.buildOnGround = true;
		b.size.Set(24, 40);
		blocks[3].push_back(b);
	}
	{
		BuildBlock b(0, "oiltank", "$icon_oiltank$", Translate::OilTank);
		AddRequirement(b.reqs, "blob", "mat_wood","Wood", 250);
		AddRequirement(b.reqs, "blob", "mat_ironingot", name(Translate::IronIngot), 2);
		b.buildOnGround = true;
		b.size.Set(32, 16);
		blocks[3].push_back(b);
	}
	{ //newer gen tc import
		BuildBlock b(0, "smallsign", "$icon_smallsign$", Translate::Sign);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 100);
		
		b.buildOnGround = true;
		b.size.Set(16, 16);
		blocks[3].push_back(b);
	}
	
	BuildBlock[] page_4;
	blocks.push_back(page_4);
	
	{
		BuildBlock b(0, "wire", "$wire$", "Wire");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "elbow", "$elbow$", "Elbow");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "tee", "$tee$", "Tee");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "junction", "$junction$", "Junction");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 2);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "diode", "$diode$", "Diode");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "resistor", "$resistor$", "Resistor");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "inverter", "$inverter$", "Inverter");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "oscillator", "$oscillator$", "Oscillator");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "transistor", "$transistor$", "Transistor");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "toggle", "$toggle$", "Toggle");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "randomizer", "$randomizer$", "Randomizer");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 20);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "lever", "$lever$", "Lever");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "push_button", "$pushbutton$", "Button");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "coin_slot", "$coin_slot$", "Coin Slot");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "pressure_plate", "$pressureplate$", "Pressure Plate");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "sensor", "$sensor$", "Motion Sensor");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "lamp", "$lamp$", "Lamp");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 1);
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 10);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "emitter", "$emitter$", "Emitter");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 2);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "receiver", "$receiver$", "Receiver");
		AddRequirement(b.reqs, "blob", "mat_copperwire", name(Translate::CopperWire), 2);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "magazine", "$magazine$", "Magazine");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 20);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "bolter", "$bolter$", "Bolter");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "dispenser", "$dispenser$", "Dispenser");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 30);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "obstructor", "$icon_obstructor$", "Obstructor");
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[4].push_back(b);
	}
	{
		BuildBlock b(0, "spiker", "$spiker$", "Spiker");
		AddRequirement(b.reqs, "blob", "mat_wood", "Wood", 10);
		AddRequirement(b.reqs, "blob", "mat_stone", "Stone", 40);
		blocks[4].push_back(b);
	}
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
