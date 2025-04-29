#version 120

varying vec2 texcoord;
varying vec4 vertexColor;
varying vec3 normal;

uniform sampler2D texture;

/* DRAWBUFFERS:012 */

void main() {
    vec4 baseColor = texture2D(texture, texcoord) * vertexColor;
    if (baseColor.a < 0.05) discard;

    // Cotton candy tint
    const vec3 dayWaterColor = vec3(1.0, 0.8, 0.9);  // pink
    vec3 waterColor = mix(baseColor.rgb, dayWaterColor, 0.6);

    gl_FragData[0] = vec4(waterColor, baseColor.a);
    gl_FragData[1] = vec4(normal * 0.5 + 0.5, 1.0);
    gl_FragData[2] = vec4(gl_MultiTexCoord1.st, 0.0, 1.0);
}