void mainImage(out vec4 col, in vec2 p) {
	p /= iResolution.xy;
    p.y = 1. - p.y;
    col = mix(texture(previous, p), vec4(1., 0., 0., 0.), 0.005);
}
