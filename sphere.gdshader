shader_type spatial;

uniform float H;
uniform vec3 displacement;
uniform float rot_intensity;
uniform float DENSITY = 512.f;
uniform vec3 base_color = vec3(0.83, 0.65, 0.31);

float hash(uint n) {
	// integer hash copied from Hugo Elias
	n = (n << 13U) ^ n;
	n = n * (n * n * 15731U + 789221U) + 1376312589U;
	return float(n & uint(0x7fffffffU)) / float(0x7fffffff);
}

void vertex() {
	// Rotational displacement :
	float loc_rot_int = length(VERTEX.xz) * rot_intensity;
	vec3 rot_dir = cross(NORMAL, vec3(0, 1.f, 0));
	
	vec3 deltaV = NORMAL + H * (displacement + rot_dir * loc_rot_int);
	VERTEX += 0.2 * H * normalize(deltaV);
	UV = vec2(2.f, 1.f) * UV;
}

void fragment() {
	vec2 iUV = floor(UV * DENSITY);
	
	vec2 loc_space = fract(UV * DENSITY) * 2.f - 1.f;
	
	ALBEDO = vec3(loc_space, 0);
	
	uint seed = uint(iUV.x + DENSITY * iUV.y);

	float rand = hash(seed);
	float p = (1.f - H / rand);

	if (length(loc_space) < 2.f * p ) {
		ALBEDO = base_color * (0.2 + 0.8 * H);
	}
	else {
		discard;
	}
}
