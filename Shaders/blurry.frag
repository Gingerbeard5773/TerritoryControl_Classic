//guassian blur shader
//gingerbeard got this from chatgpt LOL

uniform sampler2D baseMap;
uniform float blur_strength;
uniform float screen_width;
uniform float screen_height;

void main()
{
    vec2 tex_size = vec2(1.0f / screen_width, 1.0f / screen_height);
    vec2 tex_offset = blur_strength * tex_size;
    vec2 uv = gl_TexCoord[0].xy;
    vec3 color = vec3(0.0);
    float weight_sum = 0.0;

    for (int x = -2; x <= 2; x++)
    {
        for (int y = -2; y <= 2; y++)
        {
            float weight = exp(-(x * x + y * y) / (2.0 * blur_strength * blur_strength));
            vec2 offset = vec2(float(x), float(y)) * tex_offset;
            color += texture2D(baseMap, uv + offset).rgb * weight;
            weight_sum += weight;
        }
    }

    color /= weight_sum;
    gl_FragColor = vec4(color, 1.0);
}
