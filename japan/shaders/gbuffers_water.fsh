#version 330 compatibility

uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform sampler2D fake_reflection_color;
uniform vec3 cameraPos;

uniform float alphaTestRef = 0.1;

in vec2 lmcoord;
in vec2 texcoord;
in vec4 glcolor;

in vec3 worldNormal;
in vec3 worldPos;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	vec3 n = normalize(worldNormal);
	if (length(n) < 0.001) n = vec3(0.0, 1.0, 0.0);
    vec3 v = normalize(cameraPos - worldPos);
    vec3 r = reflect(-v, n);

	vec2 reflection_texcoord = texcoord + r.xz * 0.05;

	reflection_texcoord = clamp(reflection_texcoord, 0.001, 0.999);
    vec4 reflection_texture = texture(fake_reflection_color, reflection_texcoord);
	color = texture(gtexture, texcoord) * glcolor;
	color *= texture(lightmap, lmcoord);

	color = mix(color, reflection_texture, 0.5);

	if (color.a < alphaTestRef) {
		discard;
	}
}