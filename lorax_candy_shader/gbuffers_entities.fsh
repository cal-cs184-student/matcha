#version 120

varying vec2 texcoord;
varying vec4 vertexColor;
varying vec3 normal;

uniform sampler2D texture;

/* DRAWBUFFERS:012 */

void main() {
    vec4 albedo = texture2D(texture, texcoord) * vertexColor;
    if (albedo.a < 0.1) discard;

    gl_FragData[0] = albedo;
    gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
    gl_FragData[2] = vec4(gl_MultiTexCoord1.st, 0.0, 1.0);
}