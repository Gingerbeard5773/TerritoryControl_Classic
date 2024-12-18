//Territory Control Settings

void onInit(CRules@ this)
{
	const SColor print_col(0xff66C6FF);
	
	const string original_version = "v58";
	const string remaster_version = "v8";
	
	sv_mapcycle_shuffle = true;
	
	sv_contact_info = "discord.gg/PAERqSb"; //information to display when an error occurs
	
	sv_name = "[EU] Territory Control Classic: Blurry Badgers";

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
	print("GoldenGuy   |  Contributor & Russian Translator", print_col);
	print("Vamist      |  Hoster", print_col);
	print("");
}

//Changelog v8 December 17, 2024
//
// Fixed mustard gas turning into methane when vaccumed.
// Faction leadership is reset when the leader leaves the faction.
// Fixed incorrect faction defeat message.
// Improved collision with projectiles and collisions with gaseous blobs.
// Guns do not break while held.
// Added a mod compatible pickup menu.
// Gas bypasses vehicle immunity.
// Explosion effects will always appear on clients.
// Ported over the pickup crash fix.
// 2v1 votes will pass.
// Added operetta to the map cycle.
//
