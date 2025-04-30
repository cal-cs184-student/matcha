#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	float k, c = 50.0, 0.005;
	vec2 newtexcoord = texcoord + vec2(sin(texcoord.y * k) * c, cos(texcoord.x * k) * c);

	// normal code
	color = texture(gtexture, newtexcoord) * glcolor;
	color *= texture(lightmap, lmcoord);
	if (color.a < alphaTestRef) {
		discard;
	}
}