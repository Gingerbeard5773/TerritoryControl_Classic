//Gun Cursor

#include "GunCommon.as";

void onRender(CSprite@ this)
{
	CBlob@ blob = this.getBlob();
	if (blob is null || !blob.isMyPlayer()) return;

	CBlob@ item = blob.getCarriedBlob();
	if (item is null || !item.hasTag("gun")) return;
	
	GunInfo@ gun;
	if (!item.get("gunInfo", @gun)) return;

	CHUD@ hud = getHUD();
	hud.SetCursorImage("WeaponCursor.png", Vec2f(32, 32));
	hud.SetCursorOffset(Vec2f(-32, -32));

	if (!gun.reloading || gun.reload_shotgun)
	{
		hud.SetCursorFrame(Maths::Clamp((gun.ammo == 0 ? 0.0f : 1.0f) + Maths::Round((f32(gun.ammo) / f32(gun.ammo_max)) * 7.0f), 0, 8));
	}
	else
	{
		const int relative = getGameTime() - gun.reload_time + gun.reload_delay;
		hud.SetCursorFrame(Maths::Clamp(1.0f + Maths::Floor((f32(relative) / f32(gun.reload_delay)) * 7.0f), 0, 8));
	}

	hud.ShowCursor();
}
