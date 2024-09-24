//Territory Control Settings

void onInit(CRules@ this)
{
	const SColor print_col(0xff66C6FF);
	
	const string original_version = "v56";
	const string remaster_version = "v4";
	
	sv_mapcycle_shuffle = true;
	
	sv_contact_info = "discord.gg/PAERqSb"; //information to display when an error occurs
	
	sv_name = "[EU] Territory Control Classic: Improved badgers";

	print("");
	print("    --- INITIALIZING TERRITORY CONTROL CLASSIC REMASTERED ---", print_col);
	print("");
	print("MOD INFO", print_col);
	print("Original Version  | "+original_version, print_col);
	print("Remaster Version  | "+remaster_version, print_col);
	print("Server Name       | "+sv_name, print_col);
	print("");
	print("Discord: "+sv_contact_info, print_col);
	print("Github: https://github.com/Gingerbeard5773/TerritoryControl_Classic", print_col);
	print("");
	print("IMPORTANT INFORMATION!", print_col);
	print("The public is not authorized to host this variation of TC without permission!", print_col);
	print("Permission can be granted by contacting Gingerbeard @ giggerbeard (discord username).", print_col);
	print("");
	print("CREDITS TO THESE INDIVIDUALS", print_col);
	print("TFlippy     |  Creator", print_col);
	print("Pirate Rob  |  Contributor", print_col);
	print("Mirsario    |  Contributor", print_col);
	print("Cesar0      |  Contributor", print_col);
	print("Sylw        |  Contributor", print_col);
	print("Vamist      |  Hoster", print_col);
	print("");
}

//Changelog v4 Sept 24, 2024
//
// Removed methane dupe.
// Extractors and autoforges apply pickup delay to materials.
// Fixed non-explodable bombs caused by bombers dying.
// Fixed an issue with meteors' emitsound appearing when joining the server.
// Fixed an issue where sound from emotes wouldn't play due to ping.
// Copper rates lowered somewhat.
// Added 'Store' button for the assembler.
// Fixed cards not properly colliding.
// Bombers collide with enemy bombers.
// Bombers can open doors.
// Bombers' hitboxes are larger.
// Various bombs no longer damage through walls.
// Platforms block explosion damage from getting through.
// Drill rig doesn't get damaged when drilling bedrock.
// Storages give remote access if they are within range of a faction base.
// Hoppers and chests' inventories are now added onto remote storage.
// Captured witchshacks give regeneration to players anywhere on the map.
// Damage tweaks to bombers, armored bombers and steamtanks.
//