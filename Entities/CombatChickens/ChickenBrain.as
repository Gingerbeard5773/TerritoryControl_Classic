#include "BrainCommon.as";
#include "BrainPathing.as";

const f32 detection_radius = 350.0f;    // distance it takes to initially 'see' players
const f32 target_lose_radius = 450.0f;  // distance it takes to start losing target
const u16 target_lose_time = 30*6;      // time it takes to lose a target

void onInit(CBlob@ this)
{
	this.set_u16("target_lose_timer", target_lose_time);
	this.set_u32("nextAttack", 20);
	
	PathHandler handler(this.getTeamNum(), Path::GROUND);
	this.set("path_handler", @handler);
}

void onTick(CBlob@ this)
{
	if (!isServer() || this.getPlayer() !is null || this.hasTag("dead"))
	{
		this.getCurrentScript().tickFrequency = -1; //turn off
		return;
	}

	PathHandler@ handler;
	if (!this.get("path_handler", @handler)) return;

	handler.Tick(this.getPosition());
	
	const bool flyer = this.isAttachedToPoint("FLYER");
	const bool gunner = this.isAttachedToPoint("GUNNER");
	
	if (gunner)
	{
		EndPath(this);
	}

	SetSuggestedKeys(this, flyer);
	SetSuggestedFacing(this);

	CBrain@ brain = this.getBrain();
	CBlob@ target = SearchTarget(this, brain);
	if (target !is null && !flyer)
	{	
		Vec2f target_pos = target.getPosition();
		const f32 distance = (target_pos - this.getPosition()).Length();
		f32 visibleDistance;
		const bool visibleTarget = isVisible(this, target, visibleDistance);

		this.setKeyPressed(key_action1, false);
		
		u16 lose_time = this.get_u16("target_lose_timer");
		if (distance > target_lose_radius)
		{
			lose_time = Maths::Max(lose_time - 1, 0);
			this.set_u16("target_lose_timer", lose_time);
		}

		if (target.hasTag("dead") || lose_time == 0) 
		{
			this.set_u16("target_lose_timer", target_lose_time);
			brain.SetTarget(null);
			return;
		}

		if (visibleTarget && visibleDistance < 35.0f) 
		{
			EndPath(this);
			DefaultRetreatBlob(this, target);
		}	
		else if ((getGameTime() + this.getNetworkID()) % 50 == 0 && !gunner)
		{
			SetPath(this, target_pos);
		}

		if (visibleTarget && distance < detection_radius + (gunner ? 90 : 0))
		{
			Vec2f randomness = Vec2f((100 - XORRandom(200)) * 0.1f, (100 - XORRandom(200)) * 0.1f);
			Vec2f newAimPos = Vec2f_lerp(this.getAimPos(), target_pos + randomness, 0.25f);
			this.setAimPos(newAimPos);
			
			// Handle attack logic
			const bool fire_delay = this.get_u32("nextAttack") < getGameTime() || gunner;
			if (fire_delay && (newAimPos - target_pos).Length() < 50.0f)
			{
				this.setKeyPressed(key_action1, true);
				this.set_u32("nextAttack", getGameTime() + this.get_u8("attackDelay"));
			}
			return;
		}
	}
	else
	{
		if ((getGameTime() + this.getNetworkID()) % 50 == 0)
		{
			handler.Repath(this.getPosition());
		}

		if ((getGameTime() + this.getNetworkID()) % 30 == 0)
		{
			this.set_u16("target_lose_timer", target_lose_time);
			this.setKeyPressed(key_action1, false);
			this.set_u32("nextAttack", getGameTime() + 50);
			RandomTurn(this);
		}

		FloatInWater(this);
	}
	
}

CBlob@ SearchTarget(CBlob@ this, CBrain@ brain)
{
	CBlob@ target = brain.getTarget();
	if (target is null && (getGameTime() + this.getNetworkID()) % 30 == 0)
	{
		@target = getNewTarget(this);
		brain.SetTarget(target);
	}
	return target;
}

CBlob@ getNewTarget(CBlob@ this)
{
	CBlob@[] players;
	getBlobsByTag("player", @players);

	for (uint i = 0; i < players.length; i++)
	{
		CBlob@ potential = players[i];
		if (this.getTeamNum() == potential.getTeamNum()) continue;
		if ((potential.getPosition() - this.getPosition()).getLength() > detection_radius) continue;
		if (potential.hasTag("dead") || potential.hasTag("migrant")) continue;
		
		if (isVisible(this, potential)) 
		{
			return potential;
		}
	}
	return null;
}

f32 onHit(CBlob@ this, Vec2f worldPoint, Vec2f velocity, f32 damage, CBlob@ hitterBlob, u8 customData)
{
	// Set target to who ever hurt us
	CPlayer@ player = hitterBlob.getDamageOwnerPlayer();
	CBrain@ brain = this.getBrain();
	if (isServer() && player !is null && brain.getTarget() is null)
	{
		CBlob@ blob = player.getBlob();
		if (blob !is null)
		{
			brain.SetTarget(blob);
		}
	}
	
	return damage;
}

/// DEBUG

void onRender(CSprite@ this)
{
	if (!render_paths) return;

	CBlob@ blob = this.getBlob();
	if (blob.hasTag("dead")) return;

	PathHandler@ handler;
	if (!blob.get("path_handler", @handler)) return;

	const SColor col(0xff66C6FF);
	Driver@ driver = getDriver();
	
	// Draw low-level boundary
	//GUI::DrawCircle(blob.getScreenPos(), tilesize * 28 * 2 * getCamera().targetDistance, col);
	
	// Draw high-level boundary
	//GUI::DrawCircle(blob.getScreenPos(), tilesize * 70 * 2 * getCamera().targetDistance, ConsoleColour::ERROR);

	// Draw target position
	/*if (handler.destination != Vec2f_zero)
	{
		Vec2f destination = driver.getScreenPosFromWorldPos(handler.destination);
		GUI::DrawCircle(destination, 16.0f, ConsoleColour::ERROR);
	}*/

	// Draw low-level path
	for (int i = 1; i < handler.path.length; i++)
	{
		Vec2f current = driver.getScreenPosFromWorldPos(handler.path[i]);
		Vec2f previous = driver.getScreenPosFromWorldPos(handler.path[i - 1]);
		GUI::DrawArrow2D(previous, current, col);
	}
	
	// Draw stuck nodes
	const string[]@ cached_keys = handler.cached_waypoints.getKeys();
	for (int i = 0; i < cached_keys.length; i++)
	{
		CachedWaypoint@ cached_waypoint;
		if (!handler.cached_waypoints.get(cached_keys[i], @cached_waypoint)) continue;
		
		if (handler.waypoints.length > 0 && handler.waypoints[0] == cached_waypoint.position) continue;

		Vec2f stuck_waypoint = driver.getScreenPosFromWorldPos(cached_waypoint.position);
		GUI::DrawCircle(stuck_waypoint, 10.0f, cached_waypoint.stuck ? ConsoleColour::CRAZY : ConsoleColour::WARNING);
	}
	
	if (handler.waypoints.length > 0)
	{
		// Draw high level path
		/*for (int i = 1; i < handler.waypoints.length; i++)
		{
			Vec2f waypoint = driver.getScreenPosFromWorldPos(handler.waypoints[i]);
			GUI::DrawCircle(waypoint, 9.0f, ConsoleColour::RCON);
		}*/

		// Draw current waypoint goal
		Vec2f next_waypoint = driver.getScreenPosFromWorldPos(handler.waypoints[0]);
		GUI::DrawCircle(next_waypoint, 8.0f, col);
	}
}
