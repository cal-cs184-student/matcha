#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D cherry_blossom;
uniform vec4 mc_Entity;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	// DEBUG print block id -> all objects are black (except sky and pets)
	int blockId = int(mc_Entity.x);
	// float id = mc_Entity.x / 255.0; // Normalize for RGB display
	// color = vec4(id, id, id, 1.0);  // Grayscale debug
	// return;

	bool isLeaf = (
		blockId == 18  || // oak leaves
		blockId == 161 || // acacia leaves
		blockId == 162 // dark oak leaves
	);

	if (isLeaf) {
		vec4 cherryBlossomColor = texture(cherry_blossom, texcoord * 4.0);
		color = cherryBlossomColor * glcolor;
		// color = vec4(1.0, 0.4, 0.7, 1.0); // bright pink to debug
	} else {
		color = texture(gtexture, texcoord) * glcolor;
	}

	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}
}