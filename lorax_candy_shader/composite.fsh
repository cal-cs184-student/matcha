#version 120

varying vec2 TexCoords;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform int worldTime;
uniform float near;
uniform float far;

/* DRAWBUFFERS:0 */

void main() {
    vec3 Albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(2.2));
    vec3 Normal = normalize(texture2D(colortex1, TexCoords).rgb * 2.0 - 1.0);
    vec2 LightmapCoords = texture2D(colortex2, TexCoords).rg;
    float Depth = texture2D(depthtex0, TexCoords).r;

    if (Depth == 1.0) {
        // Sky pixel, just show albedo
        gl_FragData[0] = vec4(Albedo, 1.0);
        return;
    }

    float sunAngle = float(worldTime) / 24000.0 * 6.28318; // 0 to 2PI
    float dayBlend = (cos((sunAngle - 3.14159)) + 1.0) * 0.5;

    vec3 pastelDay   = vec3(1.0, 0.9, 0.95);  // Light pink
    vec3 pastelNight = vec3(0.85, 0.8, 1.0);  // Light purple

    vec3 ambientColor = mix(pastelNight, pastelDay, dayBlend);

    // ⬇️ Lightmap override: keep very bright pastel lighting, ignore dark shadows
    float blockLight = max(LightmapCoords.x, 0.4); // Force minimum blocklight
    float skyLight = max(LightmapCoords.y, 0.6);   // Force minimum skylight

    vec3 lighting = (ambientColor * 1.2) * (blockLight * 0.5 + skyLight * 0.5);

    // Add a soft sun diffuse
    vec3 sunDirection = normalize(vec3(0.2, 1.0, 0.2));
    float sunDiffuse = max(dot(Normal, sunDirection), 0.0);

    lighting += ambientColor * sunDiffuse * 0.4;

    // Blend the color
    vec3 finalColor = Albedo * lighting;

    // BOOST pastel brightness for grass/leaves etc
    finalColor = mix(finalColor, vec3(1.0, 0.9, 1.0), 0.2);

    // Add light fog
    float z = Depth * 2.0 - 1.0;
    float linearDepth = (2.0 * near * far) / (far + near - z * (far - near));
    float fogFactor = clamp((linearDepth - 48.0) / (150.0 - 48.0), 0.0, 1.0);

    vec3 fogColor = mix(vec3(1.0, 0.85, 1.0), vec3(0.8, 0.7, 0.95), dayBlend);

    vec3 foggedColor = mix(finalColor, fogColor, fogFactor);

    gl_FragData[0] = vec4(foggedColor, 1.0);
}
