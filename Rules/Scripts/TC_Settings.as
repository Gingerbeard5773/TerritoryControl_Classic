//Territory Control Settings

void onInit(CRules@ this)
{
	const SColor print_col(0xff66C6FF);
	
	const string original_version = "v58";
	const string remaster_version = "v9";
	
	sv_mapcycle_shuffle = true;
	
	sv_contact_info = "https://discord.gg/V29BBeba3C"; //information to display when an error occurs
	
	sv_name = "[EU] Territory Control Classic: Drunk Badgers";

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

//Changelog v9 February 1st, 2025
//
// Added tavern.
// Added beer & vodka.
// Added choker gem.
// Added bubble gem.
// Added the map saver.
// Extractor now has optional filter functionality.
// Automat is must more resistant to damage.
// Peasants can place dirt blocks.
// The pickup menu is improved drastically.
// Nerfed tank cannon fire rate.
// Peasants have resupply
