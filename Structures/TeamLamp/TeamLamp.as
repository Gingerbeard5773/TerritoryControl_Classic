﻿
SColor[] colors =
{
	SColor(255, 50, 20, 255), // Blue
	SColor(255, 255, 50, 20), // Red
	SColor(255, 50, 255, 20), // Green
	SColor(255, 255, 20, 255), // Magenta
	SColor(255, 255, 128, 20), // Orange
	SColor(255, 20, 255, 255), // Cyan
	SColor(255, 128, 128, 255), // Violet
};

void onInit(CBlob@ this)
{
	this.getShape().SetRotationsAllowed(false);
	this.getShape().getConsts().mapCollisions = false;
    this.getSprite().getConsts().accurateLighting = false;  
	this.getSprite().SetZ(-50); //background

	this.Tag("builder always hit");

	this.SetLight(true);
	this.SetLightRadius(80.0f);
	this.SetLightColor(this.getTeamNum() < colors.length ? colors[this.getTeamNum()] : SColor(255, 255, 255, 255));
}

void onChangeTeam(CBlob@ this, const int oldTeam)
{
	this.SetLightColor(this.getTeamNum() < colors.length ? colors[this.getTeamNum()] : SColor(255, 255, 255, 255));
}

bool canBePickedUp(CBlob@ this, CBlob@ byBlob)
{
    return false;
}
