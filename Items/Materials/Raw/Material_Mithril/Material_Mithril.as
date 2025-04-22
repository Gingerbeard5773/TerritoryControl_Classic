#include "Hitters.as";
#include "TC_Translation.as";
#include "MaterialCommon.as";

void onInit(CBlob@ this)
{
	this.setInventoryName(Translate::MithrilOre);
	this.SetLight(true);
	this.SetLightRadius(24.0f);
	this.SetLightColor(SColor(255, 25, 255, 100));
	
	this.getCurrentScript().tickFrequency = 1;
	this.getCurrentScript().runFlags |= Script::tick_not_inwater | Script::tick_not_ininventory;
	
	this.maxQuantity = 250;
}

void onTick(CBlob@ this)
{
	const u16 quantity = this.getQuantity();
	if (quantity < 30) return;

	this.getCurrentScript().tickFrequency = (125 / Maths::Max(1, (quantity / 2))) * 10.0f;
	
	// print("Freq: " + this.getCurrentScript().tickFrequency + "; Quantity: " + this.getQuantity());
	
	const f32 radius = 256 * quantity / 250.0f;
	this.SetLightRadius(radius * 0.35f);
	
	if (quantity < 60) return;

	if (XORRandom(100) < 30)
	{
		if (isClient() && XORRandom(3) > 0)
		{
			// I know it's unrealistic, but people kept complaining about 'random' damage. Hopefully this'll give them the idea. :v
			// ...Let's say that KAG players have a built-in Geiger counter.
			// -- TFlippy
			
			this.getSprite().PlaySound("geiger" + (1+XORRandom(2)) + ".ogg", 0.7f, 1.0f);
		}
	
		if (isServer())
		{
			this.server_SetQuantity(quantity - 1);
		
			CBlob@[] blobsInRadius;
			if (getMap().getBlobsInRadius(this.getPosition(), radius, @blobsInRadius))
			{
				for (int i = 0; i < blobsInRadius.length; i++)
				{
					CBlob@ blob = blobsInRadius[i];
					if (blob.getName() == this.getName() && this.getDistanceTo(blob) <= Material::MERGE_RADIUS)
					{
						Material::attemptMerge(this, blob);
						continue;
					}

					if (!blob.hasTag("flesh") || blob.hasTag("dead")) continue;
					
					const f32 distMod = Maths::Max(0, (1 - ((this.getPosition() - blob.getPosition()).Length() / radius)));
					if (XORRandom(100) < 100.0f * distMod)
					{
						this.server_Hit(blob, blob.getPosition(), Vec2f(0, 0), 0.125f, Hitters::burn, true);
					}
				}
			}
		}
	}
}
