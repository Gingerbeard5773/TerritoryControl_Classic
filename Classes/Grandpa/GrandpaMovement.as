// Runner Movement Walking

#include "RunnerCommon.as"

void onInit(CMovement@ this)
{
	this.getCurrentScript().removeIfTag = "dead";
	this.getCurrentScript().runFlags |= Script::tick_not_attached;
}

void onTick(CMovement@ this)
{
	CBlob@ blob = this.getBlob();
	RunnerMoveVars@ moveVars;
	if (!blob.get("moveVars", @moveVars)) return;

	const bool left		= blob.isKeyPressed(key_left);
	const bool right	= blob.isKeyPressed(key_right);
	const bool up		= blob.isKeyPressed(key_up);
	const bool down		= blob.isKeyPressed(key_down);

	Vec2f vel = blob.getVelocity();
	CShape@ shape = blob.getShape();
	shape.SetGravityScale(0.0f);
	Vec2f force;

	if (up)    force.y -= 0.4f;
	if (down)  force.y += 0.4f;
	if (left)  force.x -= 0.4f;
	if (right) force.x += 0.4f;

	vel *= 0.90f;
	blob.setVelocity(vel);
	blob.AddForce(force * moveVars.overallScale * 100.0f);

	moveVars.jumpCount = -1;
	moveVars.fallCount = -1;

	CleanUp(this, blob, moveVars);
}

//some specific helpers

//cleanup all vars here - reset clean slate for next frame

void CleanUp(CMovement@ this, CBlob@ blob, RunnerMoveVars@ moveVars)
{
	//reset all the vars here
	moveVars.jumpFactor = 1.0f;
	moveVars.walkFactor = 1.0f;
	moveVars.stoppingFactor = 1.0f;
	moveVars.wallsliding = false;
	moveVars.canVault = true;
}
