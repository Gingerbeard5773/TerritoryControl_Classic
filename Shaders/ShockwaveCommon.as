//Gingerbeard @ April 21st, 2025

shared class Shockwave
{
	Vec2f world_pos;
	u32 time_started;
	f32 intensity;
	f32 falloff;
	
	Shockwave(Vec2f&in world_pos, const f32&in intensity, const f32&in falloff)
	{
		this.world_pos = world_pos;
		this.time_started = getGameTime();
		this.intensity = intensity;
		this.falloff = falloff;
	}
}
