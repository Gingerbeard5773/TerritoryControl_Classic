// TC Translations

// Gingerbeard @ November 8 2024

shared const string Translate(const string&in en, const string&in ru = "")
{
	string text_out = "";
	if (g_locale == "en") text_out = en; //english
	if (g_locale == "ru") text_out = ru; //russian 

	if (text_out.isEmpty()) text_out = en; //default to english if we dont have a translation

	return text_out;
}

namespace Translate
{
	const string
	
	//builder menu
	WoodTriangle   = Translate("Wooden Triangle", ""),
	StoneTriangle  = Translate("Stone Triangle",  ""),
	HalfBlock      = Translate("Stone Half Block", ""),
	IronDoor       = Translate("Iron Door\nDoesn't have to be placed next to walls!", ""),
	IronPlatform   = Translate("Iron Platform\nReinforced one-way platform. Indestructible by peasants.", ""),
	IronBlock      = Translate("Iron Plating\nA durable metal block. Indestructible by peasants.", ""),
	PlasteelBlock  = Translate("Plasteel Panel\nA highly advanced composite material. Nearly indestructible.", ""),
	DirtBlock      = Translate("Dirt\nFairly resistant to explosions.\nMay be only placed on dirt backgrounds or damaged dirt.", ""),
	Glass          = Translate("Glass\nFancy and fragile.", ""),
	GlassBack      = Translate("Glass wall\nFancy and fragile.", ""),
	
	Mechanist      = Translate("Mechanist's Workshop\nA place where you can construct various trinkets and advanced machinery. Repairs adjacent vehicles.", ""),
	Armory         = Translate("Armory\nA workshop where you can craft cheap equipment. Automatically stores nearby dropped weapons and ammunition.", ""),
	Gunsmith       = Translate("Gunsmith's Workshop\nA workshop for those who enjoy making holes. Slowly produces bullets.", ""),
	Bombshop       = Translate("Demolitionist's Workshop\nFor those with an explosive personality.", ""),
	Forge          = Translate("Forge\nEnables you to process raw metals into pure ingots and alloys.", ""),
	Yard           = Translate("Construction Yard\nUsed to construct various vehicles.", ""),
	Camp           = Translate("Camp\nA basic faction base. Can be upgraded to gain\nspecial functions and more durability.", ""),
	
	Conveyor       = Translate("Conveyor Belt\nUsed to transport items.", ""),
	Seperator      = Translate("Separator\nItems matching the filter will be launched away.", ""),
	Launcher       = Translate("Launcher\nLaunches items to the eternity and beyond.", ""),
	Filter         = Translate("Filter\nItems matching the filter won't collide with this.", ""),
	AutoForge      = Translate("Auto-Forge\nProcesses raw materials and alloys just for you.", ""),
	Assembler      = Translate("Assembler\nAn elaborate piece of machinery that manufactures items.", ""),
	DrillRig       = Translate("Driller Mole\nAn automatic drilling machine that mines resources underneath."),
	Hopper         = Translate("Hopper\nPicks up items lying on the ground.", ""),
	Extractor      = Translate("Extractor\nGrabs items from nearby inventories.", ""),
	Lamp           = Translate("Industrial Lamp\nA sturdy lamp to ligthen up the mood in your factory.\nActs as a support block.", ""),
	Grinder        = Translate("Grinder\nA dangerous machine capable of destroying almost everything.", ""),
	Packer         = Translate("Packer\nA safe machine capable of packing almost everything.", ""),
	Inserter       = Translate("Inserter\nTransfers items between inventories next to it.\nLarge funnel acts as input, small funnel as output.", ""),
	
	WoodChest      = Translate("Wooden Chest\nA regular wooden chest used for storage.\nCan be accessed by anyone.", ""),
	Locker         = Translate("Personal Locker\nA more secure way to store your items.\nCan be only accessed by the first person to claim it.", ""),
	Siren          = Translate("Air Raid Siren\nWarns of incoming enemy aerial vehicles within 75 block radius.", ""),
	LampPost       = Translate("Lamp Post\nA fancy light.", ""),
	BarbedWire     = Translate("Barbed Wire\nHurts anyone who passes through it. Good at preventing people from climbing over walls.", ""),
	TeamLamp       = Translate("Team Lamp\nGlows with your team's spirit.", ""),
	SignBoard      = Translate("Sign Board\nType '!write -text-' in chat and then use it on the sign. Writing on a paper costs 50 coins.", ""),
	StoneSilo      = Translate("Stone Silo\nAutomatically collects ores from all of your team's mines.", ""),
	OilTank        = Translate("Oil Tank\nAutomatically collects oil from all of your team's pumpjacks.", ""),
	Sign           = Translate("Sign\nType '!write -text-' in chat and then use it on the sign. Writing on a paper costs 50 coins.", ""),
	
	//peasant build menu
	Faction        = Translate("Found a Faction!", ""),
	Campfire       = Translate("Campfire", ""),
	BanditShack    = Translate("An Awful Rundown Bandit Shack\nGives you an option to become bandit scum.", ""),
	
	//builder shop
	Chair          = Translate("Chair\nQuite comfortable.", ""),
	Table          = Translate("Table\nA portable surface with 4 legs.", ""),
	
	//tinker table
	Gramophone     = Translate("Gramophone\nA device used to play music from Gramophone Records purchased at the Merchant.", ""),
	PowerDrill     = Translate("Giga Drill Breaker\nA huge overpowered drill with a durable mithril head.", ""),
	Contrabass     = Translate("Contrabass\nA musical instrument for the finest bards.", ""),
	CopperWire     = Translate("Copper Wire\nA copper wire. Kids' favourite toy.", ""),
	Klaxon         = Translate("Clown's Funny Klaxon\nAn infernal device housing thousands of lamenting souls.", ""),
	Automat        = Translate("Autonomous Activator\nA fish-operated contraption that uses anything in its tiny hands.", ""),
	GasExtractor   = Translate("Zapthrottle Gas Extractor\nA handheld air pump commonly used for cleaning, martial arts and gas cloud extraction.\n\nLeft mouse: Pull\nRight mouse: Push", ""),
	MustardGas     = Translate("Mustard Gas\nA bottle of a highly poisonous gas. Causes blisters, blindness and lung damage.", ""),
	Backpack       = Translate("Backpack\nA large leather backpack that can be equipped and used as an inventory.\nOccupies the Torso slot.", ""),
	Parachutepack  = Translate("Parachute Pack\nA backpack containing a parachute.\nOccupies the Torso slot.\nPress [Shift] to use.", ""),
	Jetpack        = Translate("Rocket Pack\nA small rocket-propelled backpack.\nOccupies the Torso slot.\nPress [Shift] to jump!", ""),
	ScubaGear      = Translate("Scuba Gear\nSpecial equipment used for scuba diving.\nOccupies the Head slot.", ""),
	
	//armory
	RoyalArmor     = Translate("Royal Guard Armor\nA heavy armor for that offers high damage resistance at cost of low mobility.", ""),
	Nightstick     = Translate("Truncheon\nA traditional tool used by seal clubbing clubs.", ""),
	Shackles       = Translate("Slavemaster's Kit\nA kit containing shackles, shiny iron ball, elegant striped pants, noisy chains and a slice of cheese.", ""),
	
	//gunsmith
	LowCalAmmo     = Translate("Low Caliber Ammunition\nBullets for pistols and SMGs.", ""),
	HighCalAmmo    = Translate("High Caliber Ammunition\nBullets for rifles. Effective against armored targets.", ""),
	ShotgunAmmo    = Translate("Shotgun Shells\nShotgun Shells for... Shotguns.", ""),
	MachinegunAmmo = Translate("Machine Gun Ammunition\nAmmunition used by the machine gun.", ""),
	Revolver       = Translate("Revolver\nA compact firearm for those with small pockets.\n\nUses Low Caliber Ammunition.", ""),
	Rifle          = Translate("Bolt Action Rifle\nA handy bolt action rifle.\n\nUses High Caliber Ammunition.", ""),
	SMG            = Translate("Bobby Gun\nA powerful submachine gun.\n\nUses Low Caliber Ammunition.", ""),
	Bazooka        = Translate("Bazooka\nA long tube capable of shooting rockets. Make sure nobody is standing behind it.\n\nUses Small Rockets.", ""),
	Scorcher       = Translate("Scorcher\nA tool used for incinerating plants, buildings and people.\n\nUses Oil.", ""),
	Shotgun        = Translate("Shotgun\nA short-ranged weapon that deals devastating damage.\n\nUses Shotgun Shells.", ""),
	
	//bombshop
	TankShell      = Translate("Artillery Shell\nA highly explosive shell used by the artillery.", ""),
	HowitzerShell  = Translate("Howitzer Shell\nA large howitzer shell capable of annihilating a cottage.", ""),
	Rocket         = Translate("Rocket of Doom\nLet's fly to the Moon. (Not really)", ""),
	BigBomb        = Translate("S.Y.L.W. 9000\nA big bomb. Handle with care.", ""),
	Fragmine       = Translate("Fragmentation Mine\nA fragmentation mine that fills the surroundings with shards of metal upon detonation.", ""),
	SmallBomb      = Translate("Small Bomb\nA small iron bomb. Detonates when it hits surface with enough force.", ""),
	IncendiaryBomb = Translate("Incendiary Bomb\nSets the peasants on fire.", ""),
	BunkerBuster   = Translate("Bunker Buster\nPerfect for making holes in heavily fortified bases. Detonates upon strong impact.", ""),
	StunBomb       = Translate("Shockwave Bomb\nCreates a shockwave with strong knockback. Detonates upon strong impact.", ""),
	Nuke           = Translate("R.O.F.L.\nA dangerous warhead stuffed in a cart. Since it's heavy, it can be only pushed around or picked up by balloons.", ""),
	Claymore       = Translate("Gregor\nA remotely triggered explosive device covered in some sort of slime. Sticks to surfaces.", ""),
	SmallRocket    = Translate("Small Rocket\nSelf-propelled ammunition for rocket launchers.", ""),
	ClaymoreRemote = Translate("Gregor Remote Detonator\nA device used to remotely detonate Gregors.", ""),
	SmokeGrenade   = Translate("Smoke Grenade\nA small hand grenade used to quickly fill a room with smoke. It helps you keep out of sight.", ""),
	
	//construction yard
	SteamTank      = Translate("Steam Tank\nAn armored land vehicle. Comes with a powerful cannon and a durable ram.", ""),
	Machinegun     = Translate("Machine Gun\nUseful for making holes.", ""),
	Mortar         = Translate("Mortar\nMortar combat!", ""), 
	Bomber         = Translate("Bomber\nA large aerial vehicle used for safe transport and bombing the peasants below.", ""),
	ArmoredBomber  = Translate("Armored Bomber\nA fortified but slow moving balloon with an iron basket and two attachment slots. Resistant against gunfire.", ""),
	Howitzer       = Translate("Howitzer\nMortar's bigger brother.", ""),
	RocketLauncher = Translate("Rocket Launcher\nA rapid-fire rocket launcher especially useful against aerial targets.", ""),
	
	//camp
	Upgrades       = Translate("Upgrades & Repairs", ""),
	UpgradeCamp    = Translate("Upgrade to a Fortress\nUpgrade to a more durable Fortress.\n\n+ Higher inventory capacity\n+ Extra durability\n+ Tunnel travel", ""),
	Repair         = Translate("Repair\nRepair this badly damaged building.\nRestores 5% of building's integrity.", ""),
	JoinFaction    = Translate("Join the Faction", ""),
	Defeated       = Translate("{LOSER} has been defeated by the {WINNER}!", ""),
	Defeat         = Translate("{LOSER} has been defeated!", ""),
	
	//bandit shack
	RatDen         = Translate("Rat's Den", ""),
	RatBurger      = Translate("Tasty Rat Burger\nI always ate this as a kid.", ""),
	RatFood        = Translate("Very Fresh Rat\nI caught this rat myself.", ""),
	SellChow       = Translate("My favourite meal. I'll give you {COINS} coins for this!", ""),
	SellChow2      = Translate("My grandma loves this traditional dish.", ""),
	BanditPistol   = Translate("Lite Pistal\nMy grandma made this pistol.", ""),
	BanditRifle    = Translate("Timbr Grindr\nI jammed two pipes in this and it kills people and works it's good.", ""),
	BanditAmmo     = Translate("Kill Pebles\nMy grandpa made these.", ""),
	Faultymine     = Translate("A Working Mine\nYou should buy this mine.", ""),

	//generic shop
	Buy            = Translate("Buy {ITEM} ({QUANTITY})", ""),
	Buy2           = Translate("Buy {QUANTITY} {ITEM} for {COINS} coins.", ""),
	Sell           = Translate("Sell {ITEM} ({QUANTITY})", ""),
	Sell2          = Translate("Sell {QUANTITY} {ITEM} for {COINS} coins.", ""),
	
	//merchant
	MusicDisc      = Translate("Gramophone Record\nA random gramophone record.", ""),
	Tree           = Translate("Tree Seed\nA tree seed. Trees don't have seeds, though.", ""),
	Cake           = Translate("Cinnamon Bun\nA pastry made with love.", ""),
	Car            = Translate("Motorized Horse\nMakes you extremely cool.", ""),

	//coalmine
	CoalMine       = Translate("Coalville Mining Company", ""),

	//witch
	WitchShack     = Translate("Witch's Dilapidated Shack", ""),
	ProcessMithril = Translate("Process Mithril\nI shall remove the deadly curse from this mythical metal.", ""),
	CardPack       = Translate("Funny Magical Card Booster Pack\nA full pack of fun!", ""),
	MysteryBox     = Translate("Mystery Box\nWhat's inside?\nInconceivable wealth, eternal suffering, upset badgers? Who knows! Only for 75 coins!", ""),
	
	//molecular fabricator
	Reconstruct    = Translate("Reconstruct {ITEM}", ""),
	Deconstruct    = Translate("Deconstruct {ITEM}", ""),
	Transmute      = Translate("Transmute {ITEM} to {RESULT}", ""),
	Transmute2     = Translate("Transmute {QUANTITY} {ITEM} into {RECIEVED} {RESULT}.", ""),
	BustedScyther  = Translate("Busted Scyther Component\nA completely useless garbage, brand new.", ""),
	ChargeRifle    = Translate("Charge Rifle\nA burst-fire energy weapon.", ""),
	ChargeLance    = Translate("Charge Lance\nAn extremely powerful rail-assisted handheld cannon.", ""),
	Exosuit        = Translate("Exosuit\nA standard issue Model II Exosuit.", ""),
	Scyther        = Translate("Scyther\nA light combat mechanoid equipped with a Charge Lance.", ""),
	Fabricator     = Translate("Molecular Fabricator\nA highly advanced machine capable of restructuring molecules and atoms.", ""),
	
	//phone
	Phone          = Translate("SpaceStar Ordering!", ""),
	ChickenSquad   = Translate("Combat Chicken Assault Squad!\nGet your own soldier... TODAY!", ""),
	Minefield      = Translate("Portable Minefield!\nA brave flock of landmines! No more trespassers!", ""),

	//generic factory
	Flip           = Translate("Flip direction", ""),
	TurnOn         = Translate("Turn On", ""),
	TurnOff        = Translate("Turn Off", ""),

	//assembler
	SetAssembler   = Translate("Set to Assemble", ""),
	AlreadySet     = Translate("Already Assembling", ""),
	
	//packer
	SetPacker      = Translate("Set packing threshold", ""),
	Increment      = Translate("Increment Packing Threshold ({STACKS} stacks)", ""),
	Decrement      = Translate("Decrement Packing Threshold ({STACKS} stacks)", ""),

	//materials
	CopperOre      = Translate("Copper", ""),
	IronOre        = Translate("Iron", ""),
	Coal           = Translate("Coal", ""),
	Dirt           = Translate("Dirt", ""),
	Sulphur        = Translate("Sulphur", ""),
	MithrilOre     = Translate("Mithril", ""),
	Oil            = Translate("Oil", ""),
	Methane        = Translate("Methane", ""),
	Meat           = Translate("Mystery Meat", ""),
	Matter         = Translate("Amazing Technicolor Dust", ""),
	Plasteel       = Translate("Plasteel Sheets\nA durable yet lightweight material.", ""),
	LanceRod       = Translate("Metal Rods\nA bundle of 10 tungsten rods.", ""),
	CopperIngot    = Translate("Copper Ingot\nA soft conductive metal.", ""),
	IronIngot      = Translate("Iron Ingot\nA fairly strong metal used to make tools, equipment and such.", ""),
	SteelIngot     = Translate("Steel Ingot\nMuch stronger than iron, but also more expensive.", ""),
	GoldIngot      = Translate("Gold Ingot\nA fancy metal - traders' favourite.", ""),
	MithrilIngot   = Translate("Mithril Ingot", ""),
	
	//equipment
	Equip          = Translate("Equip {ITEM}", ""),
	Unequip        = Translate("Unequip {ITEM}", ""),
	
	//events
	AncientShip    = Translate("A strange object has fallen out of the sky!", ""),
	MeteorEvent    = Translate("A bright flash illuminates the sky.", ""),
	ScytherEvent   = Translate("A Scyther has arrived!", ""),

	//other
	ScrubChow      = Translate("Scrub Chow", ""),
	ScrubChowXL    = Translate("Scrub Chow XL", ""),
	Certificate    = Translate("Building for Dummies", ""),
	InfernalStone  = Translate("Infernal Stone", "");
}

string name(const string&in translated)
{
	const string[]@ tokens = translated.split("\n");
	if (tokens.length == 0) return "FAILED NAME - CONSULT TRANSLATIONS";
	return tokens[0];
}

string desc(const string&in translated)
{
	const int token = translated.findFirst("\n");
	if (token == -1) return "FAILED DESCRIPTION - CONSULT TRANSLATIONS";
	return translated.substr(token + 1);
}

string buy(const string&in item, const string&in quantity, const string&in coins = "")
{
	string result = coins.isEmpty() ? Translate::Buy : Translate::Buy2;
	result = result.replace("{ITEM}", getTranslatedString(item)).replace("{QUANTITY}", quantity).replace("{COINS}", coins);
	return result;
}

string sell(const string&in item, const string&in quantity, const string&in coins = "")
{
	string result = coins.isEmpty() ? Translate::Sell : Translate::Sell2;
	result = result.replace("{ITEM}", getTranslatedString(item)).replace("{QUANTITY}", quantity).replace("{COINS}", coins);
	return result;
}
