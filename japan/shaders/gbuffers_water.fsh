#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D fake_reflection_color;
uniform vec3 cameraPos;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

in worldNormal;
in worldPos;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec3 n = normalize(worldNormal);
    vec3 v = normalize(cameraPos - worldPos);
    vec3 r = reflect(-v, n);

	vec2 reflection_texcoord = texcoord + r.xy * 0.1;
    vec4 reflection_texture = texture(fake_reflection_color, reflection_texcoord);
	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);

	color = mix(color, reflection, 0.5);

	if (color.a < alphaTestRef) {
		discard;
	}
}