#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(getTranslatedInventoryName(this));
}

string getTranslatedInventoryName(CBlob@ this)
{
	const string blob_name = this.getName();
	if (blob_name == "cake")      return name(Translate::Cake);
	if (blob_name == "ratfood")   return name(Translate::RatFood);
	if (blob_name == "ratburger") return name(Translate::RatBurger);
	if (blob_name == "foodcan")   return name(Translate::ScrubChow);

	return this.getInventoryName();
}
