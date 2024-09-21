#include "EquipmentCommon.as";

void onInit(CBlob@ this)
{
	this.set_string("equipment_slot", "head");

	addOnEquip(this, @OnEquip);
	addOnUnequip(this, @OnUnequip);
}

void OnEquip(CBlob@ this, CBlob@ equipper)
{
	CSprite@ sprite = equipper.getSprite();
	CSpriteLayer@ buckethead = sprite.addSpriteLayer("buckethead", "BucketHead.png", 16, 16);
	if (buckethead !is null)
	{
		buckethead.SetVisible(true);
		buckethead.SetRelativeZ(0.5f);
		buckethead.SetFacingLeft(sprite.isFacingLeft());
	}
	
	sprite.AddScript("BucketEffect.as");
}

void OnUnequip(CBlob@ this, CBlob@ equipper)
{
	CSprite@ sprite = equipper.getSprite();
	sprite.RemoveSpriteLayer("buckethead");
	sprite.RemoveScript("BucketEffect.as");
}
