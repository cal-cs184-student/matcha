#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

// new stuff to be outputted by this file and fed into gbuffers_water.fsh
out vec3 worldNormal;
out vec3 worldPos;

uniform mat4 gbuffer_model_view;
uniform mat4 gbuffer_model_view_inverse;
uniform mat4 gbuffer_projection;
uniform mat3 normal;

// automatically defined by minecraft thank GOD
in vec4 gl_Vertex;
in vec3 gl_Normal;

void main() {
	vec4 view = gbuffer_model_view * gl_Vertex;

	// building outputs
    worldPos = view.xyz;
    worldNormal = normalize(normal * gl_Normal);

	gl_Position = gbuffer_projection * view; // remove blackbox function that uses model_view and projection to compute gl_pos
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;
}