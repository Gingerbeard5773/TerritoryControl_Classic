bool canEat(CBlob@ blob)
{
	return blob.exists("eat sound");
}

// returns the healing amount of a certain food (in quarter hearts) or 0 for non-food
u8 getHealingAmount(CBlob@ food)
{
	if (!canEat(food))
	{
		return 0;
	}

	const string name = food.getName();

	if (name == "heart")           return 4;
	else if (name == "ratburger")  return 4;
	else if (name == "ratfood")    return 3;
	else if (name == "food")       return 7;
	else if (name == "cake")       return 5;
	else if (name == "foodcan")    return 8;
	else if (name == "egg")        return 7;
	else if (name == "grain")      return 4;

	return 255; // full healing
}

void Heal(CBlob@ this, CBlob@ food)
{
	bool exists = getBlobByNetworkID(food.getNetworkID()) !is null;
	if (isServer() && this.hasTag("player") && this.getHealth() < this.getInitialHealth() && !food.hasTag("healed") && exists)
	{
		u8 heal_amount = getHealingAmount(food);

		if (heal_amount == 255)
		{
			this.add_f32("heal amount", this.getInitialHealth() - this.getHealth());
			this.server_SetHealth(this.getInitialHealth());
		}
		else
		{
			f32 oldHealth = this.getHealth();
			this.server_Heal(f32(heal_amount) * 0.25f);
			this.add_f32("heal amount", this.getHealth() - oldHealth);
		}

		//give coins for healing teammate
		if (food.exists("healer"))
		{
			CPlayer@ player = this.getPlayer();
			u16 healerID = food.get_u16("healer");
			CPlayer@ healer = getPlayerByNetworkId(healerID);
			if (player !is null && healer !is null)
			{
				bool healerHealed = healer is player;
				bool sameTeam = healer.getTeamNum() == player.getTeamNum();
				if (!healerHealed && sameTeam)
				{
					int coins = 10;
					healer.server_setCoins(healer.getCoins() + coins);
				}
			}
		}

		this.Sync("heal amount", true);

		food.Tag("healed");

		food.SendCommand(food.getCommandID("heal command client")); // for sound

		food.server_Die();
	}
}
