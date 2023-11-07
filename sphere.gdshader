shader_type spatial;

// Aesthetics parameters
uniform float L = 0.4;								// strand length
uniform float DENSITY = 512.f;						// hair density
uniform vec3 base_color = vec3(0.83, 0.65, 0.31);	// base color

// Required parameters
uniform float H;
// shell layer
uniform mat4 del_transf;
// movement transform (with inverse exponential persistence)

float hash(vec2 v) {
	vec2 iUV = floor(v * DENSITY);
	uint n = uint(iUV.x + DENSITY * iUV.y);
	
	// integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
	n = n * (n * n * 15731U + 789221U) + 1376312589U;
	return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
}

void vertex() {
	// Applying fake physics
	vec3 tip = VERTEX + L * NORMAL;
	vec3 displacement = (del_transf * vec4(tip, 1)).xyz - tip;
	vec3 delta = normalize(NORMAL + H * displacement);
	
	// Avoiding clipping at high rotation speed (doesn't work as expected)
	float proj = dot(delta, NORMAL);
	delta = delta + NORMAL * (1.f - proj);
	
	VERTEX += L * sqrt(H) * normalize(delta);
	
	// To enforce circular strands on the equator (instead of ellipsises)
	UV = vec2(2.f, 1.f) * UV;
}

void fragment() {
	vec2 loc_space = fract(UV * DENSITY) * 2.f - 1.f;

	float rand = hash(UV);
	float p = (1.f - H / rand);

	if (length(loc_space) < 2.f * p ) {
		ALBEDO = base_color * (0.2 + 0.8 * H);
	}
	else {
		discard;
	}
}
