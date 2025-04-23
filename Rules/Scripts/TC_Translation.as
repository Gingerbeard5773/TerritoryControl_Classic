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
	WoodTriangle   = Translate("Wooden Triangle", "Деревянный треугольник"),
	StoneTriangle  = Translate("Stone Triangle",  "Каменный треугольник"),
	HalfBlock      = Translate("Stone Half Block", "Каменный полублок"),
	IronDoor       = Translate("Iron Door\nDoesn't have to be placed next to walls!", "Железная дверь\nЕго не обязательно размещать рядом со стенами!"),
	IronPlatform   = Translate("Iron Platform\nReinforced one-way platform. Indestructible by peasants.", "Железная платформа\nУсиленная односторонняя платформа. Не поддается разрушению крестьянами."),
	IronBlock      = Translate("Iron Plating\nA durable metal block. Indestructible by peasants.", "Железная панель\nПрочный металлический блок. Не поддается разрушению крестьянами."),
	PlasteelBlock  = Translate("Plasteel Panel\nA highly advanced composite material. Nearly indestructible.", "Панель из пластистали\nВысокоэффективный композитный материал. Практически не поддается разрушению."),
	DirtBlock      = Translate("Dirt\nFairly resistant to explosions.\nMay be only placed on dirt backgrounds or damaged dirt.", "Земля\nДовольно устойчива к взрывам.\nРазрешается размещать только на земляном фоне или поврежденной земле."),
	Glass          = Translate("Glass\nFancy and fragile.", "Стекло\nПричудливая и хрупкая."),
	GlassBack      = Translate("Glass wall\nFancy and fragile.", "Стеклянная стена\nПричудливая и хрупкая."),

	Mechanist      = Translate("Mechanist's Workshop\nA place where you can construct various trinkets and advanced machinery. Repairs adjacent vehicles.", "Мастерская механика\nМесто, где вы можете создавать различные безделушки и современную технику. Ремонтируйте транспортные средства находящиеся рядом."),
	Armory         = Translate("Armory\nA workshop where you can craft cheap equipment. Automatically stores nearby dropped weapons and ammunition.", "Арсенал\nМастерская, где вы можете изготовить дешевое снаряжение. Автоматически подбирает брошенное поблизости оружии и боеприпасы."),
	Gunsmith       = Translate("Gunsmith's Workshop\nA workshop for those who enjoy making holes. Slowly produces bullets.", "Мастерская оружейника\nМастерская для тех, кто любит проделывать дырки. Медленно изготавливает пули."),
	Bombshop       = Translate("Demolitionist's Workshop\nFor those with an explosive personality.", "Мастерская подрывника\nДля тех, у кого взрывной характер."),
	Forge          = Translate("Forge\nEnables you to process raw metals into pure ingots and alloys.", "Кузница\nПозволяет перерабатывать необработанные металлы в чистые слитки и сплавы."),
	Yard           = Translate("Construction Yard\nUsed to construct various vehicles.", "Строительная площадка\nИспользуется для конструирования различных транспортных средств."),
	Camp           = Translate("Camp\nA basic faction base. Can be upgraded to gain\nspecial functions and more durability.", "Лагерь\nБазовая фракционная база. Может быть улучшен для получения специальных функций и большей прочности."),

	Conveyor       = Translate("Conveyor Belt\nUsed to transport items.", "Конвейерная лента\nИспользуется для транспортировки предметов."),
	Seperator      = Translate("Separator\nItems matching the filter will be launched away.", "Разделитель\Предметы, соответствующие фильтру, будут выброшены."),
	Launcher       = Translate("Launcher\nLaunches items to the eternity and beyond.", "Пусковая установка\nОтправляет предметы в бесконечность и за далее!"),
	Filter         = Translate("Filter\nItems matching the filter won't collide with this.", "Фильтр\nПредметы, соответствующие фильтру, будут проходить сквозь него."),
	AutoForge      = Translate("Auto-Forge\nProcesses raw materials and alloys just for you.", "Автоматическая кузница\nОбрабатывает сырье и сплавы специально для вас."),
	Assembler      = Translate("Assembler\nAn elaborate piece of machinery that manufactures items.", "Сборщик\nСложное оборудование, которое производит предметы."),
	DrillRig       = Translate("Driller Mole\nAn automatic drilling machine that mines resources underneath.", "Крот-бурильщик\nАвтоматический буровой станок, который добывает ресурсы под ней."),
	Hopper         = Translate("Hopper\nPicks up items lying on the ground.", "Воронка\nПоднимает предметы, лежащие на земле."),
	Extractor      = Translate("Extractor\nGrabs items from nearby inventories.", "Экстрактор\nЗахватывает предметы из ближайших запасов."),
	Lamp           = Translate("Industrial Lamp\nA sturdy lamp to lighten up the mood in your factory.\nActs as a support block.", "Промышленная лампа\nПрочная лампа, которая поднимет настроение на вашем заводе.\nДействует как опорный блок."),
	Grinder        = Translate("Grinder\nA dangerous machine capable of destroying almost everything.", "Измельчитель\nОпасная машина, способная уничтожить практически все."),
	Packer         = Translate("Packer\nA safe machine capable of packing almost everything.", "Упаковщик\nБезопасная машина, способная упаковывать практически все."),
	Inserter       = Translate("Inserter\nTransfers items between inventories next to it.\nLarge funnel acts as input, small funnel as output.", "Вставщик\nПереносит предметы между соседними инвентарями.\nБольшая воронка служит входом, маленькая - выходом."),

	WoodChest      = Translate("Wooden Chest\nA regular wooden chest used for storage.\nCan be accessed by anyone.", "Деревянный сундук\nОбычный деревянный сундук, используемый для хранения вещей.\nДоступ к нему может получить любой желающий."),
	Locker         = Translate("Personal Locker\nA more secure way to store your items.\nCan be only accessed by the first person to claim it.", "Личный шкафчик\nБолее безопасный способ хранения ваших вещей.\nДоступ к нему может получить только тот, кто первым присвоит его."),
	Siren          = Translate("Air Raid Siren\nWarns of incoming enemy aerial vehicles within 75 block radius.", "Сирена воздушной тревоги\nПредупреждает о приближении вражеских летательных аппаратов в радиусе 75 блоков."),
	LampPost       = Translate("Lamp Post\nA fancy light.", "Фонарный столб\nКрасивый фонарь."),
	BarbedWire     = Translate("Barbed Wire\nHurts anyone who passes through it. Good at preventing people from climbing over walls.", "Колючая проволока\nПричиняет боль любому, кто проходит через неё. Хорошо помогает людям не перелезать через ваши стены."),
	TeamLamp       = Translate("Team Lamp\nGlows with your team's spirit.", "Командная лампа\nСветится духом вашей команды."),
	SignBoard      = Translate("Sign Board\nType '!write -text-' in chat and then use it on the sign. Writing on a paper costs 50 coins.", "Вывеска\n\nВведите '!write -текст-' в чате а затем используйте бумажку на табличке. Написать на бумажке стоит 50 монет"),
	StoneSilo      = Translate("Stone Silo\nAutomatically collects ores from all of your team's mines.", "Каменный элеватор\nАвтоматически собирает руду со всех шахт вашей команды."),
	OilTank        = Translate("Oil Tank\nAutomatically collects oil from all of your team's pumpjacks.", "Нефтяной резервуар\nАвтоматически собирает нефть из всех насосных станций вашей команды."),
	Sign           = Translate("Sign\nType '!write -text-' in chat and then use it on the sign. Writing on a paper costs 50 coins.", "Табличка\nВведите '!write -текст-' в чате а затем используйте бумажку на табличке. Написать на бумажке стоит 50 монет"),

	//peasant build menu
	Faction        = Translate("Found a Faction!", "Создать фракцию!"),
	Campfire       = Translate("Campfire", "Походный костер"),
	Tavern         = Translate("Tavern\nA poorly built cozy tavern.\nOther neutrals may set their spawn here, paying you 20 coins for each spawn.", "Таверна\nПлохо построенная, уютная таверна.\nДругие нейтралы могут разместить здесь свою точку возрождения, платя вам 20 монет за каждую точку появления."),
	BanditShack    = Translate("An Awful Rundown Bandit Shack\nGives you an option to become bandit scum.", "Ужасная захудалая бандитская лачуга\nДает вам возможность стать бандитом-подонком."),

	//builder shop
	Chair          = Translate("Chair\nQuite comfortable.", "Стул\nДовольно удобное."),
	Table          = Translate("Table\nA portable surface with 4 legs.", "Стол\nПереносная поверхность с 4 ножками."),

	//tinker table
	Gramophone     = Translate("Gramophone\nA device used to play music from Gramophone Records purchased at the Merchant.", "Грамофон\nУстройство, используемое для воспроизведения музыки с грампластинок, приобретенных в магазине."),
	PowerDrill     = Translate("Giga Drill Breaker\nA huge overpowered drill with a durable mithril head.", "Гига буровая установка\nОгромное мощное сверло с прочной мифриловой головкой."),
	Contrabass     = Translate("Contrabass\nA musical instrument for the finest bards.", "Контрабас\nМузыкальный инструмент для лучших бардов."),
	CopperWire     = Translate("Copper Wire\nA copper wire. Kids' favourite toy.", "Медная проволока\nЛюбимая игрушка детей."),
	Klaxon         = Translate("Clown's Funny Klaxon\nAn infernal device housing thousands of lamenting souls.", "Забавный клаксон клоуна\nАдское устройство, вмещающее тысячи плачущих душ."),
	Automat        = Translate("Autonomous Activator\nA fish-operated contraption that uses anything in its tiny hands.", "Автономный активатор\nПриспособление, управляемое рыбой, которое использует все, что находится в ее крошечных ручках."),
	GasExtractor   = Translate("Zapthrottle Gas Extractor\nA handheld air pump commonly used for cleaning, martial arts and gas cloud extraction.\n\nLeft mouse: Pull\nRight mouse: Push", "Газоотводчик с запорным клапаном\nРучной воздушный насос, обычно используемый для уборки помещений, занятий боевыми искусствами и засасывания газовых облаков.\n\nЛевый клик: Втягивать\nПравый клик: Выдув"),
	MustardGas     = Translate("Mustard Gas\nA bottle of a highly poisonous gas. Causes blisters, blindness and lung damage.", "Горчичный газ\nБаллончик с очень ядовитым газом. Вызывает образование волдырей, слепоту и повреждение легких."),
	Backpack       = Translate("Backpack\nA large leather backpack that can be equipped and used as an inventory.\nOccupies the Torso slot.", "Рюкзак\nБольшой кожаный рюкзак, который можно надеть и использовать в качестве инвентаря.\nЗанимает место для туловища."),
	Parachutepack  = Translate("Parachute Pack\nA backpack containing a parachute.\nOccupies the Torso slot.\nPress [Shift] to use.", "Парашютный ранец\nРюкзак с парашютом.\nЗанимает место для туловища.\nНажми [Shift] чтобы использовать."),
	Jetpack        = Translate("Rocket Pack\nA small rocket-propelled backpack.\nOccupies the Torso slot.\nPress [Shift] to jump!", "Ракетный ранец\nНебольшой рюкзак с реактивным двигателем.\nЗанимает место для туловища.\nНажми [Shift] для прыжка!"),
	ScubaGear      = Translate("Scuba Gear\nSpecial equipment used for scuba diving.\nOccupies the Head slot.", "Акваланг\nСпециальное снаряжение, используемое для подводного плавания.\nЗанимает место для головы."),

	//armory
	RoyalArmor     = Translate("Royal Guard Armor\nA heavy armor that offers high damage resistance at cost of low mobility.", "Доспехи королевской гвардии\nТяжелая броня, обладающая высокой устойчивостью к урону но и низкой подвижностью."),
	Nightstick     = Translate("Truncheon\nA traditional tool used by seal clubbing clubs.", "Дубинка\nТрадиционный инструмент, используемый морскими клубами."),
	Shackles       = Translate("Slavemaster's Kit\nA kit containing shackles, shiny iron ball, elegant striped pants, noisy chains and a slice of cheese.", "Набор рабовладельца\nНабор, состоящий из кандалов, блестящего железного шара, элегантных полосатых штанов, шумных цепей и ломтика сыра."),

	//gunsmith
	LowCalAmmo     = Translate("Low Caliber Ammunition\nBullets for pistols and SMGs.", "Боеприпасы малого калибра\nПатроны для пистолетов и автоматов SMG."),
	HighCalAmmo    = Translate("High Caliber Ammunition\nBullets for rifles. Effective against armored targets.", "Крупнокалиберные боеприпасы\nПули для винтовок. Эффективны против бронированных целей."),
	ShotgunAmmo    = Translate("Shotgun Shells\nShotgun Shells for... Shotguns.", "Патроны для дробовика\n...патроны для дробовика"),
	MachinegunAmmo = Translate("Machine Gun Ammunition\nAmmunition used by the machine gun.", "Боеприпасы к пулемету\nБоеприпасы, используемые пулеметом."),
	Revolver       = Translate("Revolver\nA compact firearm for those with small pockets.\n\nUses Low Caliber Ammunition.", "Револьвер\nКомпактное огнестрельное оружие для тех, у кого маленькие карманы.\n\nИспользует боеприпасы большого калибра."),
	Rifle          = Translate("Bolt Action Rifle\nA handy bolt action rifle.\n\nUses High Caliber Ammunition.", "Винтовка с затвором\nУдобная винтовка с затвором.\n\n"),
	SMG            = Translate("Bobby Gun\nA powerful submachine gun.\n\nUses Low Caliber Ammunition.", "Бобби Ган\nМощный пистолет-пулемет.\n\nИспользует боеприпасы малого калибра."),
	Bazooka        = Translate("Bazooka\nA long tube capable of shooting rockets. Make sure nobody is standing behind it.\n\nUses Small Rockets.", "Базука\nДлинная труба, способная стрелять ракетами. Убедитесь, что за ней никто не стоит.\n\nИспользует Маленькие Ракеты."),
	Scorcher       = Translate("Scorcher\nA tool used for incinerating plants, buildings and people.\n\nUses Oil.", "Выжигатель\nИнструмент, используемый для сжигания растений, зданий и людей.\n\nnИспользует нефть."),
	Shotgun        = Translate("Shotgun\nA short-ranged weapon that deals devastating damage.\n\nUses Shotgun Shells.", "Дробовик\nОружие ближнего боя, наносящее сокрушительный урон.\n\nИспользует патроны для дробовика."),

	//bombshop
	TankShell      = Translate("Artillery Shell\nA highly explosive shell used by the artillery.", "Артиллерийский снаряд\nОсколочно-фугасный снаряд, используемый артиллерией."),
	HowitzerShell  = Translate("Howitzer Shell\nA large howitzer shell capable of annihilating a cottage.", "Гаубичный снаряд\nБольшой гаубичный снаряд, способный уничтожить целый участок."),
	Rocket         = Translate("Rocket of Doom\nLet's fly to the Moon. (Not really)", "Ракета погибели\nДавай полетим на Луну. (Не совсем)"),
	BigBomb        = Translate("S.Y.L.W. 9000\nA big bomb. Handle with care.", "S.Y.L.W. 9000\nБольшая бомба. Обращайтесь с ней осторожно."),
	Fragmine       = Translate("Fragmentation Mine\nA fragmentation mine that fills the surroundings with shards of metal upon detonation.", "Осколочная мина\nОсколочная мина, которая при детонации наполняет окрестности металлическими осколками."),
	SmallBomb      = Translate("Small Bomb\nA small iron bomb. Detonates when it hits surface with enough force.", "Маленькая бомба\nМаленькая железная бомба. Взрывается, когда ударяется о поверхность с достаточной силой."),
	IncendiaryBomb = Translate("Incendiary Bomb\nSets the peasants on fire.", "Зажигательная бомба\nПоджигает крестьян."),
	BunkerBuster   = Translate("Bunker Buster\nPerfect for making holes in heavily fortified bases. Detonates upon strong impact.", "Разрушитель бункеров\nИдеально подходит для проделывания отверстий в сильно укрепленных базах. Взрывается при сильном ударе."),
	StunBomb       = Translate("Shockwave Bomb\nCreates a shockwave with strong knockback. Detonates upon strong impact.", "Бомба с ударной волной\nСоздает ударную волну с сильной отдачей. Детонирует при сильном ударе."),
	Nuke           = Translate("R.O.F.L.\nA dangerous warhead stuffed in a cart. Since it's heavy, it can be only pushed around or picked up by balloons.", "Р.О.Ф.Л.\nОпасная боеголовка, запиханная в тележку. Поскольку она тяжелая, ее можно только толкать или поднимать с помощью воздушных шаров."),
	Claymore       = Translate("Gregor\nA remotely triggered explosive device covered in some sort of slime. Sticks to surfaces.", "Грегор\nВзрывное устройство с дистанционным управлением, покрытое какой-то слизью. Прилипает к поверхности."),
	SmallRocket    = Translate("Small Rocket\nSelf-propelled ammunition for rocket launchers.", "Маленькая ракета\nСамоходные боеприпасы для ракетных установок."),
	ClaymoreRemote = Translate("Gregor Remote Detonator\nA device used to remotely detonate Gregors.", "Дистанционный детонатор Грегоров\nУстройство, использовавшееся для дистанционного подрыва Грегоров."),
	SmokeGrenade   = Translate("Smoke Grenade\nA small hand grenade used to quickly fill a room with smoke. It helps you keep out of sight.", "Дымовая граната\nНебольшая ручная граната, используемая для быстрого заполнения помещения дымом. Помогает оставаться незамеченным."),

	//construction yard
	SteamTank      = Translate("Steam Tank\nAn armored land vehicle. Comes with a powerful cannon and a durable ram.", "Паровой танк\nБронированный наземный автомобиль. Оснащен мощной пушкой и прочным тараном."),
	Machinegun     = Translate("Machine Gun\nUseful for making holes.", "Пулемёт\nХорошо проделывает отверстия."),
	Mortar         = Translate("Mortar\nMortar combat!", "Миномёт\n(шутка про мортал комбат)"), 
	Bomber         = Translate("Bomber\nA large aerial vehicle used for safe transport and bombing the peasants below.", "Бомбардировщик\nБольшой летательный аппарат, используемый для безопасной транспортировки и бомбардировки крестьян."),
	ArmoredBomber  = Translate("Armored Bomber\nA fortified but slow moving balloon with an iron basket and two attachment slots. Resistant against gunfire.", "Бронированный бомбардировщик\nУкрепленный, но медленно движущийся воздушный шар с железной корзиной и двумя креплениями. Устойчив к огнестрельному оружию."),
	Howitzer       = Translate("Howitzer\nMortar's bigger brother.", "Гаубица\nСтарший брат миномёта."),
	RocketLauncher = Translate("Rocket Launcher\nA rapid-fire rocket launcher especially useful against aerial targets.", "Ракетная установка\nСкорострельная ракетная установка, особенно полезная для борьбы с воздушными целями."),

	//faction
	Fortress       = Translate("Fortress", "Крепость"),
	Upgrades       = Translate("Upgrades & Repairs", "Модернизация и ремонт"),
	UpgradeCamp    = Translate("Upgrade to a Fortress\nUpgrade to a more durable Fortress.\n\n+ Higher inventory capacity\n+ Extra durability\n+ Tunnel travel", "Модернизировать в крепость\nУлучшите свою крепость до более прочной.\n\n+ Более высокий объем складских запасов\n+ Дополнительная прочность\n+ Перемещение по туннелю"),
	Repair         = Translate("Repair\nRepair this badly damaged building.\nRestores 5% of building's integrity.", "Отремонтировать\nОтремонтируйте это сильно поврежденное здание.\nВосстанавливает 5% целостности здания."),
	JoinFaction    = Translate("Join the Faction", "Вступить во фракцию"),
	FactionManage  = Translate("Faction Management", "Управление фракцией"),
	CannotJoin0    = Translate("Cannot join!\nThis faction has too many players.", "Невозможно присоединиться!\nВ этой фракции слишком много игроков."),
	CannotJoin1    = Translate("Cannot join!\nThis faction is not accepting any new members.", "Невозможно присоединиться!\nЭта фракция не принимает новых членов."),
	Enable         = Translate("Enable {POLICY}", "Включить {POLICY}"),
	Disable        = Translate("Disable {POLICY}", "Отключить {POLICY}"),
	Recruitment    = Translate("Recruitment\nDecide if players are allowed to join your faction.", "Вербовка\nРешите, разрешено ли игрокам вступать в вашу фракцию."),
	Lockdown       = Translate("Lockdown\nDecide if neutrals can pass through your doors.", "Запертые двери\nРешите, могут ли нейтралы проходить через ваши двери"),
	ClaimLeader    = Translate("Claim Leadership\nClaim leadership of this faction.", "Заявите о лидерстве\nЗаявите о лидерстве в этой фракции."),
	ResignLeader   = Translate("Resign Leadership\nResign from faction leadership.", "Уйти\nУйти с поста лидера фракции."),
	LeaderReset    = Translate("Your faction no longer has a leader.", "У вашей фракции больше нет лидера."),
	LeaderClaim    = Translate("{PLAYER} is now the leader of your faction.", "{PLAYER} теперь лидер вашей фракции."), 
	Defeated       = Translate("{LOSER} has been defeated by the {WINNER}!", "{LOSER} были побеждены {WINNER}!"),
	Defeat         = Translate("{LOSER} has been defeated!", "{LOSER} были побеждены!"),

	//bandit shack
	RatDen         = Translate("Rat's Den", "Крысиное логово"),
	RatBurger      = Translate("Tasty Rat Burger\nI always ate this as a kid.", "Вкусный крысиный бургер\nЯ всегда ел это в детстве."),
	RatFood        = Translate("Very Fresh Rat\nI caught this rat myself.", "Очень свежая крыса\nЯ сам поймал эту крысу."),
	SellChow       = Translate("My favourite meal. I'll give you {COINS} coins for this!", "Мое любимое блюдо. За это я дам тебе {COINS} монет!"),
	SellChow2      = Translate("My grandma loves this traditional dish.", "Моя бабушка обожает это традиционное блюдо."),
	BanditPistol   = Translate("Lite Pistal\nMy grandma made this pistol.", "Лёгкй пистлет\nЭтот пистолет сделала моя бабушка."),
	BanditRifle    = Translate("Timbr Grindr\nI jammed two pipes in this and it kills people and works it's good.", "Измльчитль дрвесны\nЯ вставил в это две трубки, и это убивает людей и работает хорошо."),
	BanditAmmo     = Translate("Kill Pebles\nMy grandpa made these.", "Смертоносная галька\nИх делал мой дедушка."),
	Faultymine     = Translate("A Working Mine\nYou should buy this mine.", "Работающая шахта\nВам следует купить эту шахту."),
	
	//tavern
	FunTavern      = Translate("Fun Tavern!", "Веселая Таверна!"),
	Beer           = Translate("Beer's Bear\nHomemade fresh bear with foam!", "Пиво\nДомашнее свежее пиво с пеной!"),
	Beer2          = Translate("A real beer for real men. Those who drink Bear's Bear are strong men.", "Настоящее пиво для настоящих мужчин. Те, кто пьют пиво — сильные мужчины."),
	Vodka          = Translate("Vodka!\nAlso homemade fun water, buy this!", "Водка!\nТакже домашняя водичка, купите ее!"),
	BanditMusic    = Translate("Bandit Music\nPlays a bandit music!", "Бандитская музыка\nВоспроизводит бандитскую музыку!"),
	TavernRat      = Translate("It doesn't bite because I hit it with a roller", "Он не кусается, потому что я бью его роликом."),
	TavernBurger   = Translate("FLUFFY BURGER", "ПУШИСТЫЙ БУРГЕР"),
	ShoddyTavern0  = Translate("Shoddy Tavern", "Шодди Таверна"),
	ShoddyTavern1  = Translate("{OWNER}'s Shoddy Tavern", "Шодди Таверна ({OWNER})"),
	SetTavern      = Translate("Set this as your current spawn point.\n(Costs 20 coins per respawn)", "Установите это как текущую точку появления.\n(Стоит 20 монет за возрождение.)"),
	UnsetTavern    = Translate("Unset this as your current spawn point.", "Удалите это как текущую точку появления."),

	//generic shop
	Buy            = Translate("Buy {ITEM} ({QUANTITY})", "Купить {ITEM} ({QUANTITY})"),
	Buy2           = Translate("Buy {QUANTITY} {ITEM} for {COINS} coins.", "Купить {QUANTITY} {ITEM} за {COINS} монет."),
	Sell           = Translate("Sell {ITEM} ({QUANTITY})", "Продать {ITEM} ({QUANTITY})"),
	Sell2          = Translate("Sell {QUANTITY} {ITEM} for {COINS} coins.", "Продать {QUANTITY} {ITEM} за {COINS} монет."),

	//merchant
	Merchant       = Translate("Merchant", "Купец"),
	MusicDisc      = Translate("Gramophone Record\nA random gramophone record.", "Грампластинка\nСлучайная грампластинка."),
	Tree           = Translate("Tree Seed\nA tree seed. Trees don't have seeds, though.", "Семя дерева\nСемя дерева... Но ведь у деревьев нет семян..."),
	Cake           = Translate("Cinnamon Bun\nA pastry made with love.", "Булочка с корицей\nВыпечка, приготовленная с любовью."),
	Car            = Translate("Motorized Horse\nMakes you extremely cool.", "Железный конь\nСделает тебя невероятно крутым."),

	//coalmine
	CoalMine       = Translate("Coalville Mining Company", "Горнодобывающая компания Коулвилла"),

	//pumpjack
	PumpJack       = Translate("Pump Jack", "Масляный насос"),

	//witch
	WitchShack     = Translate("Witch's Dilapidated Shack", "Полуразрушенная хижина ведьмы"),
	ProcessMithril = Translate("Process Mithril\nI shall remove the deadly curse from this mythical metal.", "Обработать Мифрил\nЯ сниму смертельное проклятие с этого мифического металла."),
	CardPack       = Translate("Funny Magical Card Booster Pack\nA full pack of fun!", "Забавный набор волшебных карт\nПолный набор развлечений!"),
	MysteryBox     = Translate("Mystery Box\nWhat's inside?\nInconceivable wealth, eternal suffering, upset badgers? Who knows! Only for 75 coins!", "Таинственная шкатулка\nЧто внутри?\nНемыслимое богатство, вечные страдания, дикие барсуки? Кто знает! Всего за 75 монет!"),
	BubbleGem      = Translate("Terdla's Bubble Gem\nA useless pretty blue gem!", "Камень-пузырь Тердлы\nБесполезный красивый синий самоцвет!"),
	Choker         = Translate("Verdla's Suffocation Charm\nA pretty green smokey gem!", "Удушающие чары Вердлы\nКрасивый дымчатый зеленый самоцвет!"),

	//molecular fabricator
	Reconstruct    = Translate("Reconstruct {ITEM}", "Воссоздать {ITEM}"),
	Deconstruct    = Translate("Deconstruct {ITEM}", "Разобрать {ITEM}"),
	Transmute      = Translate("Transmute {ITEM} to {RESULT}", "Преобразовать {ITEM} в {RESULT}"),
	Transmute2     = Translate("Transmute {QUANTITY} {ITEM} into {RECIEVED} {RESULT}.", "Преобразовать {QUANTITY} {ITEM} в {RECIEVED} {RESULT}."),
	BustedScyther  = Translate("Busted Scyther Component\nA completely useless garbage, brand new.", "Сломанная часть Скифера\nСовершенно бесполезный мусор, абсолютно новый."),
	ChargeRifle    = Translate("Charge Rifle\nA burst-fire energy weapon.", "Энерго винтовка\nЭнергетическое оружие, стреляющее очередями."),
	ChargeLance    = Translate("Charge Lance\nAn extremely powerful rail-assisted handheld cannon.", "Энерго копьё\nЧерезвычайно мощный ручной рельсотрон."),
	Exosuit        = Translate("Exosuit\nA standard issue Model II Exosuit.", "Экзокостюм\nСтандартный экзокостюм Model II."),
	Scyther        = Translate("Scyther\nA light combat mechanoid equipped with a Charge Lance.", "Скифер\nЛегкий боевой механоид, оснащенный энерго копьем."),
	Fabricator     = Translate("Molecular Fabricator\nA highly advanced machine capable of restructuring molecules and atoms.", "Молекулярный производитель\nВысокоразвитая машина, способная перестраивать молекулы и атомы."),

	//phone
	Phone          = Translate("SpaceStar Ordering!", "КосмоСтар Доставка!"),
	ChickenSquad   = Translate("Combat Chicken Assault Squad!\nGet your own soldier... TODAY!", "Боевой куриный штурмовой отряд!\nЗаведите себе собственного солдата... СЕГОДНЯ ЖЕ!"),
	Minefield      = Translate("Portable Minefield!\nA brave flock of landmines! No more trespassers!", "Портативное минное поле!\nОтважная стая мин! Больше никаких нарушителей границы!"),

	//generic factory
	Flip           = Translate("Flip direction", "Поменять направление"),
	TurnOn         = Translate("Turn On", "Включить"),
	TurnOff        = Translate("Turn Off", "Выключить"),

	//assembler
	SetAssembler   = Translate("Set to Assemble", "Установить для сборки"),
	AlreadySet     = Translate("Already Assembling", "Уже собирается"),

	//packer
	SetPacker      = Translate("Set packing threshold", "Установить порог упаковки"),
	Increment      = Translate("Increment Packing Threshold ({STACKS} stacks)", "Увеличить порог упаковки ({STACKS} стопок)"),
	Decrement      = Translate("Decrement Packing Threshold ({STACKS} stacks)", "Уменьшить порог упаковки ({STACKS} стопок)"),
	
	//locker
	Locker0        = Translate("Personal Locker", "Персональный шкафчик"),
	Locker1        = Translate("{OWNER}'s Personal Locker", "Персональный шкафчик ({OWNER})"),
	Locker2        = Translate("{OWNER}'s Personal Safe has been destroyed!", "Личный сейф {OWNER} был уничтожен!"),

	//materials
	CopperOre      = Translate("Copper", "Медь"),
	IronOre        = Translate("Iron", "Железо"),
	Coal           = Translate("Coal", "Уголь"),
	Dirt           = Translate("Dirt", "Земля"),
	Sulphur        = Translate("Sulphur", "Сера"),
	MithrilOre     = Translate("Mithril", "Мифрил"),
	Oil            = Translate("Oil", "Нефть"),
	Methane        = Translate("Methane", "Метан"),
	Meat           = Translate("Mystery Meat", "Таинственное мясо"),
	Matter         = Translate("Amazing Technicolor Dust", "Удивительная цветная пыль"),
	Plasteel       = Translate("Plasteel Sheets\nA durable yet lightweight material.", "Листы из пластистали\nПрочный, но в то же время легкий материал."),
	LanceRod       = Translate("Metal Rods\nA bundle of 10 tungsten rods.", "Металлические стержни\nСвязка из 10 вольфрамовых стержней."),
	CopperIngot    = Translate("Copper Ingot\nA soft conductive metal.", "Медный слиток\nМягкий электропроводящий металл."),
	IronIngot      = Translate("Iron Ingot\nA fairly strong metal used to make tools, equipment and such.", "Железный слиток\nДовольно прочный металл, используемый для изготовления инструментов, оборудования и прочего."),
	SteelIngot     = Translate("Steel Ingot\nMuch stronger than iron, but also more expensive.", "Стальной слиток\nНамного прочнее железа, но и дороже."),
	GoldIngot      = Translate("Gold Ingot\nA fancy metal - traders' favourite.", "Золотой слиток\nДрагоценный металл - любимый у торговцев."),
	MithrilIngot   = Translate("Mithril Ingot", "Мифриловый слиток"),

	//equipment
	Equip          = Translate("Equip {ITEM}", "Экипировать"),
	Unequip        = Translate("Unequip {ITEM}", "Снять экипировку"),

	//events
	AncientShip    = Translate("A strange object has fallen out of the sky!", "Странный объект упал с неба!"),
	MeteorEvent    = Translate("A bright flash illuminates the sky.", "Яркая вспышка озаряет небо."),
	ScytherEvent   = Translate("A Scyther has arrived!", "Прибыл Скифер!"),

	//nuke
	ArmNuke        = Translate("Arm the R.O.F.L.!", "Вооружите Р.О.Ф.Л.!"),
	NukeOwner      = Translate("(Only by {OWNER})", "(Только {OWNER})"),
	ActivateNuke   = Translate("Set off the R.O.F.L.!", "Взрывайте Р.О.Ф.Л.!"),
	Detonation     = Translate("Detonation in {SECONDS} seconds!", "Детонация через {SECONDS} секунд!"),

	//cards
	UnpackCards    = Translate("Open the pack and see what's inside!", "Откройте упаковку и посмотрите, что внутри!"),
	HolyCards      = Translate("Holy Cards", "Святые Карты"),
	FireCards      = Translate("Fire Cards", "Карты Огня"),
	WaterCards     = Translate("Water Cards", "Карты Воды"),
	CogCards       = Translate("Gear Cards", "Карты Винтик"),
	DeathCards     = Translate("Death Cards", "Карты Смерти"),
	SteamCards     = Translate("Steam Cards", "Пар Карты"),
	MineCards      = Translate("Mine Cards", "Карты майнинга"),
	NatureCards    = Translate("Nature Cards", "Карточки природы"),
	ChaosCards     = Translate("Chaos Cards", "Карты Хаоса"),

	//other
	ScrubChow      = Translate("Scrub Chow", "Жратва"),
	ScrubChowXL    = Translate("Scrub Chow XL", "Жратва XL"),
	Certificate    = Translate("Building for Dummies", "Строительство для чайников"),
	InfernalStone  = Translate("Infernal Stone", "Адский камень"),
	Claim          = Translate("Claim", "Претензия"),
	Drink          = Translate("Drink!", "Напиток!");
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
