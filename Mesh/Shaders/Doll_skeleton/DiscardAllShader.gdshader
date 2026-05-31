shader_type spatial;
render_mode unshaded;

void vertex() {
}

void fragment() {
	discard;
	ALPHA = 0.0;
	ALPHA_SCISSOR_THRESHOLD = 1.0;
}
