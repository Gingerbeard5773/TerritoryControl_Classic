#include "TC_Translation.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(name(Translate::Exosuit));
	this.set_string("required class", "exosuit");
	this.set_Vec2f("class offset", Vec2f(0, 0));
	this.set_u8("class button radius", 10);
}
