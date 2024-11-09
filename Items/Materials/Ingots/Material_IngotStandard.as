#include "TC_Translation.as";
void onInit(CBlob@ this)
{
	this.setInventoryName(getTranslatedInventoryName(this));
	this.maxQuantity = 16;
	this.getCurrentScript().runFlags |= Script::remove_after_this;
}

string getTranslatedInventoryName(CBlob@ this)
{
	const string blob_name = this.getName();
	if (blob_name == "mat_copperingot")  return name(Translate::CopperIngot);
	if (blob_name == "mat_ironingot")    return name(Translate::IronIngot);
	if (blob_name == "mat_steelingot")   return name(Translate::SteelIngot);
	if (blob_name == "mat_goldingot")    return name(Translate::GoldIngot); 
	if (blob_name == "mat_mithrilingot") return Translate::MithrilIngot;
	return this.getInventoryName();
}
