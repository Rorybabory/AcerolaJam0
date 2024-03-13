shader_type spatial;
uniform sampler2D tex;
uniform float time = 0.5f;
uniform float brightness = 0.2f;
void vertex() {
	VERTEX.x += sin((time+VERTEX.z*30.0f)*30.0)*0.00035f;
	VERTEX.y += cos((time+VERTEX.z*30.0f)*30.0)*0.00035f;

	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = texture(tex, UV).rgb;
	EMISSION = texture(tex, UV).rgb * brightness;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
