//Territory Control Settings

void onInit(CRules@ this)
{
	const SColor print_col(0xff66C6FF);
	
	const string original_version = "v58";
	const string remaster_version = "v6";
	
	sv_mapcycle_shuffle = true;
	
	sv_contact_info = "discord.gg/PAERqSb"; //information to display when an error occurs
	
	sv_name = "[EU] Territory Control Classic: Gassy Badgers";

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

//Changelog v6 October 13, 2024
//
// Added the Inserter.
// Added glass blocks.
// Added chair and table.
// Added small sign.
// Added equipment: Scuba gear, Jetpack, Backpack, and Parachute pack.
// Added mustard gas.
// Added stun bomb.
// Added bandit rifle.
// Added wire components from base kag.
// Added Russian translation.
// Tank shells no longer destroy dirt.
// Factions are capped to 45% of the server player count.
// Fixed shop buttons not appearing.
// Fixed turrets falling through platforms/doors.
// Bullets are overhauled entirely and are their own 'object' rather than a laser raycast.
// Chickens can carry SMGs.
// Improved the chicken AI.
// Iron and plasteel have explosion penetration resistance.
//
