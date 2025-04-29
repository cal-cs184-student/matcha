#version 120

uniform int worldTime;

void main() {
    float horizonBlend = gl_FragCoord.y / 240.0; // Vertical gradient factor

    float time = float(worldTime);
    float dayBlend = (cos((time - 6000.0) * 3.14159 / 12000.0) + 1.0) * 0.5;

    // Colors for day
    vec3 dayHorizon = vec3(1.0, 0.85, 0.95); // cotton candy pink
    vec3 dayZenith  = vec3(0.9, 0.8, 1.0);   // soft lavender

    // Colors for night
    vec3 nightHorizon = vec3(0.8, 0.7, 1.0); // pastel purplish pink
    vec3 nightZenith  = vec3(0.5, 0.4, 0.7); // deeper lavender

    // Blend day and night sky colors
    vec3 horizonColor = mix(nightHorizon, dayHorizon, dayBlend);
    vec3 zenithColor = mix(nightZenith, dayZenith, dayBlend);

    // Final vertical gradient
    vec3 skyColor = mix(horizonColor, zenithColor, clamp(horizonBlend, 0.0, 1.0));

    gl_FragColor = vec4(skyColor, 1.0);
}
