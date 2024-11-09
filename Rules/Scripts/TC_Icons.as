//Gingerbeard
//Icon Tokens for TC
#define CLIENT_ONLY

#include "CustomTiles.as";

void onInit(CRules@ this)
{
	//GUI
	AddIconToken("$change_class$", "/GUI/InteractionIcons.png", Vec2f(32, 32), 12, 2);
	AddIconToken("$icon_ruins$", "Icon_Ruins.png", Vec2f(32, 32), 19);
	AddIconToken("$icon_paper$", "Paper.png", Vec2f(16, 16), 1);

	//materials
	AddIconToken("$icon_iron$", "Material_Iron.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_coal$", "Material_Coal.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_copper$", "Material_Copper.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_sulphur$", "Material_Sulphur.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_dirt$", "Material_Dirt.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_mithril$", "Material_Mithril.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_copperingot$", "Material_CopperIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_ironingot$", "Material_IronIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_steelingot$", "Material_SteelIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_goldingot$", "Material_GoldIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_mithrilingot$", "Material_MithrilIngot.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_oil$", "Material_Oil.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_copperwire$", "Material_CopperWire.png", Vec2f(9, 11), 0);
	
	//build menu
	AddIconToken("$icon_lamppost$", "LampPost.png", Vec2f(8, 24), 0);
	AddIconToken("$icon_ironlocker$", "IronLocker.png", Vec2f(16, 24), 0);
	AddIconToken("$icon_chest$", "WoodChest.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_barbedwire$", "BarbedWire.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_teamlamp$", "TeamLamp.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_industriallamp$", "IndustrialLamp.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_drillrig$", "DrillRig.png", Vec2f(24, 24), 0);
	AddIconToken("$icon_siren$", "Siren.png", Vec2f(24, 32), 0);
	AddIconToken("$icon_textsign$", "TextSign_Large.png", Vec2f(64, 16), 0);
	AddIconToken("$icon_smallsign$", "TextSign.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_forge$", "Forge.png", Vec2f(24, 24), 0);
	AddIconToken("$icon_armory$", "Armory.png", Vec2f(40, 24), 0);
	AddIconToken("$icon_gunsmith$", "Gunsmith.png", Vec2f(40, 24), 0);
	AddIconToken("$icon_bombshop$", "BombShop.png", Vec2f(40, 24), 0);
	AddIconToken("$icon_tinkertable$", "TinkerTable.png", Vec2f(40, 24), 0);
	AddIconToken("$icon_constructionyard$", "ConstructionYardIcon.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_camp$", "Camp.png", Vec2f(80, 24), 0);
	AddIconToken("$icon_storage$", "Storage.png", Vec2f(40, 24), 0);
	AddIconToken("$icon_buildershop$", "Buildershop.png", Vec2f(40, 24), 0);
	AddIconToken("$icon_quarters$", "Quarters.png", Vec2f(40, 24), 2);
	AddIconToken("$wood_triangle$", "WoodTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$stone_triangle$", "StoneTriangle.png", Vec2f(8, 8), 0);
	AddIconToken("$stone_halfblock$", "StoneHalfBlock.png", Vec2f(8, 8), 0);
	AddIconToken("$iron_door$", "1x1IronDoor.png", Vec2f(16, 8), 0);
	AddIconToken("$iron_platform$", "IronPlatform.png", Vec2f(8, 8), 0);
	AddIconToken("$iron_block$", "World.png", Vec2f(8, 8), CMap::tile_iron);
	AddIconToken("$glass_block$", "World.png", Vec2f(8, 8), CMap::tile_glass);
	AddIconToken("$glass_block_back$", "World.png", Vec2f(8, 8), CMap::tile_glass_back);
	AddIconToken("$plasteel_block$", "World.png", Vec2f(8, 8), CMap::tile_plasteel);
	AddIconToken("$ground_block$", "World.png", Vec2f(8, 8), CMap::tile_ground);
	AddIconToken("$icon_conveyor$", "Conveyor.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_separator$", "Seperator.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_filter$", "Filter.png", Vec2f(24, 8), 0);
	AddIconToken("$icon_launcher$", "Launcher.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_autoforge$", "AutoForge.png", Vec2f(24, 32), 0);
	AddIconToken("$icon_assembler$", "Assembler.png", Vec2f(40, 24), 0);
	AddIconToken("$icon_hopper$", "Hopper.png", Vec2f(24, 24), 0);
	AddIconToken("$icon_extractor$", "Extractor.png", Vec2f(16, 24), 0);
	AddIconToken("$icon_grinder$", "Grinder.png", Vec2f(40, 24), 0);
	AddIconToken("$icon_stonepile$", "StonePile.png", Vec2f(24, 40), 3);
	AddIconToken("$icon_packer$", "Packer.png", Vec2f(24, 16), 0);
	AddIconToken("$icon_inserter$", "Inserter.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_oiltank$", "OilTank.png", Vec2f(32, 16), 0);
	
	//peasant build menu
	AddIconToken("$icon_faction$", "PeasantIcons.png", Vec2f(64, 32), 0);
	AddIconToken("$icon_banditshack$", "BanditShack.png", Vec2f(40, 24), 0);
	
	//tinkershop
	AddIconToken("$contrabass$", "Contrabass.png", Vec2f(8, 16), 0);
	AddIconToken("$gramophone$", "Gramophone.png", Vec2f(16, 16), 0);
	AddIconToken("$powerdrill$", "PowerDrill.png", Vec2f(32, 16), 0);
	AddIconToken("$icon_klaxon$", "Klaxon.png", Vec2f(24, 16), 0);
	AddIconToken("$icon_automat$", "Automat.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_gasextractor$", "GasExtractor.png", Vec2f(24, 16), 0);
	AddIconToken("$icon_mustard$", "Material_Mustard.png", Vec2f(8, 16), 0);
	AddIconToken("$icon_parachutepack$", "Parachutepack.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_scubagear$", "Scubagear.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_jetpack$", "Jetpack.png", Vec2f(16, 16), 0);
	
	//gun workshop
	AddIconToken("$icon_gatlingammo$", "Material_GatlingAmmo.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_rifleammo$", "Material_RifleAmmo.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_shotgunammo$", "Material_ShotgunAmmo.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_pistolammo$", "Material_PistolAmmo.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_rifle$", "Rifle.png", Vec2f(24, 8), 0);
	AddIconToken("$icon_smg$", "SMG.png", Vec2f(24, 8), 0);
	AddIconToken("$icon_revolver$", "Revolver.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_bazooka$", "Bazooka.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_flamethrower$", "Flamethrower.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_shotgun$", "Shotgun.png", Vec2f(24, 8), 0);
	
	//armory
	AddIconToken("$icon_royalarmor$", "RoyalArmor.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_shackles$", "Shackles.png", Vec2f(16, 8), 0);
	
	//builder shop
	AddIconToken("$artisancertificate$", "ArtisanCertificate.png", Vec2f(8, 8), 0);
	
	//bomb shop
	AddIconToken("$icon_tankshell$", "Material_TankShell.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_howitzershell$", "Material_HowitzerShell.png", Vec2f(12, 8), 0);
	AddIconToken("$icon_smallbomb$", "Material_SmallBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_incendiarybomb$", "Material_IncendiaryBomb.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_bigbomb$", "Material_BigBomb.png", Vec2f(16, 32), 0);
	AddIconToken("$icon_fragmine$", "FragMine.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_rocket$", "Rocket.png", Vec2f(24, 40), 0);
	AddIconToken("$icon_smallrocket$", "Material_SmallRocket.png", Vec2f(8, 16), 0);
	AddIconToken("$icon_nuke$", "Nuke.png", Vec2f(40, 32), 0);
	AddIconToken("$icon_claymore$", "Claymore.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_claymoreremote$", "ClaymoreRemote.png", Vec2f(8, 16), 0);
	
	//construction yard
	AddIconToken("$icon_bomber$", "Icon_Bomber.png", Vec2f(64, 64), 0);
	AddIconToken("$icon_armoredbomber$", "Icon_ArmoredBomber.png", Vec2f(64, 64), 0);
	AddIconToken("$icon_steamtank$", "Icon_Vehicles.png", Vec2f(48, 24), 0);
	AddIconToken("$icon_gatlinggun$", "Icon_Vehicles.png", Vec2f(24, 24), 2);
	AddIconToken("$icon_mortar$", "Icon_Vehicles.png", Vec2f(24, 24), 3);
	AddIconToken("$icon_howitzer$", "Icon_Vehicles.png", Vec2f(24, 24), 4);
	AddIconToken("$icon_rocketlauncher$", "Icon_Vehicles.png", Vec2f(24, 24), 5);
	
	//bandit shack
	AddIconToken("$ratburger$", "RatBurger.png", Vec2f(16, 16), 0);
	AddIconToken("$ratfood$", "Rat.png", Vec2f(16, 16), 0);
	AddIconToken("$faultymine$", "FaultyMine.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_banditpistol$", "BanditPistol.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_foodcan$", "FoodCan.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_bigfoodcan$", "BigFoodCan.png", Vec2f(16, 24), 0);
	
	//merchant
	AddIconToken("$icon_musicdisc$", "MusicDisc.png", Vec2f(8, 8), 0);
	AddIconToken("$icon_seed$", "Seed.png",Vec2f(8,8),0);
	AddIconToken("$icon_cake$", "Cake.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_car$", "Icon_Car.png", Vec2f(16, 8), 0);
	
	//witch
	AddIconToken("$card_pack$", "CardPack.png", Vec2f(9, 9), 0);
	AddIconToken("$icon_mysterybox$", "MysteryBox.png", Vec2f(24, 16), 0);
	
	//molecular Fabricator
	AddIconToken("$icon_scythergib$", "ScytherGib.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_chargerifle$", "ChargeRifle.png", Vec2f(24, 8), 0);
	AddIconToken("$icon_chargelance$", "ChargeLance.png", Vec2f(24, 8), 0);
	AddIconToken("$mat_lancerod$", "Material_LanceRod.png", Vec2f(16, 8), 0);
	AddIconToken("$icon_exosuit$", "ExosuitItem.png", Vec2f(16, 10), 0);
	AddIconToken("$icon_molecularfabricator$", "MolecularFabricator.png", Vec2f(32, 16), 0);
	AddIconToken("$icon_matter_0$", "Material_Matter.png", Vec2f(16, 16), 0);
	AddIconToken("$icon_matter_1$", "Material_Matter.png", Vec2f(16, 16), 1);
	AddIconToken("$icon_matter_2$", "Material_Matter.png", Vec2f(16, 16), 2);
	AddIconToken("$icon_matter_3$", "Material_Matter.png", Vec2f(16, 16), 3);
	AddIconToken("$icon_plasteel$", "Material_Plasteel.png", Vec2f(8, 8), 0);
	
	//phone
	AddIconToken("$ss_badger$", "SS_Icons.png", Vec2f(32, 16), 0);
	AddIconToken("$ss_raid$", "SS_Icons.png", Vec2f(16, 16), 2);
	AddIconToken("$ss_minefield$", "SS_Icons.png", Vec2f(16, 16), 3);
	
	//faction
	AddIconToken("$icon_upgrade$", "InteractionIcons.png", Vec2f(32, 32), 21);
	AddIconToken("$icon_repair$", "InteractionIcons.png", Vec2f(32, 32), 15);
	
	//travel
	for (u8 i = 0; i < this.getTeamsCount(); i++)
	{
		AddIconToken("$TRAVEL_FORTRESS_"+i+"$", "GUI/MenuItems.png", Vec2f(32, 32), 31, i);
		AddIconToken("$TRAVEL_RIGHT_"+i+"$", "GUI/InteractionIcons.png.png", Vec2f(32, 32), 17, i);
		AddIconToken("$TRAVEL_LEFT_"+i+"$", "GUI/InteractionIcons.png", Vec2f(32, 32), 18, i);
		AddIconToken("$TRAVEL_RIGHT_UP_"+i+"$", "GUI/InteractionIcons.png", Vec2f(32, 32), 6, i);
		AddIconToken("$TRAVEL_RIGHT_DOWN_"+i+"$", "GUI/InteractionIcons.png", Vec2f(32, 32), 7, i);
		AddIconToken("$TRAVEL_LEFT_UP_"+i+"$", "GUI/InteractionIcons.png", Vec2f(32, 32), 5, i);
		AddIconToken("$TRAVEL_LEFT_DOWN_"+i+"$", "GUI/InteractionIcons.png", Vec2f(32, 32), 4, i);
		AddIconToken("$TRAVEL_UP_"+i+"$", "GUI/InteractionIcons.png", Vec2f(32, 32), 16, i);
		AddIconToken("$TRAVEL_DOWN_"+i+"$", "GUI/InteractionIcons.png", Vec2f(32, 32), 19, i);
	}
}

void onReload(CRules@ this) //dev
{
	onInit(this);
}
