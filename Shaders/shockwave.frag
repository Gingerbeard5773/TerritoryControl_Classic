//shockwave shader
//gingerbeard got this from chatgpt LOL

uniform sampler2D baseMap;
uniform float screen_width;
uniform float screen_height;
uniform float count;

struct shockwave
{
	float x;
	float y;
	float time;
	float intensity;
	float falloff;
};

uniform shockwave shockwaves[10];

const float speed = 0.8;
const float thickness = 0.005;
const float amplitude = 0.015;

void main()
{
	vec2 uv = gl_FragCoord.xy / vec2(screen_width, screen_height);
	vec2 offset = vec2(0.0);

	for (int i = 0; i < 10 && i < count; i++)
	{
		vec2 center = vec2(shockwaves[i].x, shockwaves[i].y);
		vec2 dir = uv - center;
		float dist = length(dir);

		float radius = shockwaves[i].time * speed;
		float diff = dist - radius;

		float sharp_pulse = exp(-diff * diff / thickness);
		float dissipate = clamp(1.0 - (radius * shockwaves[i].falloff), 0.0, 1.0);
		float wave = sharp_pulse * dissipate * shockwaves[i].intensity;

		if (dist > 0.0)
			offset += normalize(dir) * wave * amplitude;
	}

	gl_FragColor = texture2D(baseMap, uv + offset);
}
