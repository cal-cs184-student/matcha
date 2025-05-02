#version 120
// ────────────────────────────────────────────────────────────────────────────────
//  water.fsh – standalone fantasy water
//  • procedural Gerstner‑style wave normal
//  • Schlick Fresnel mix  (refraction ↔ screen‑space reflection)
//  • simple GGX specular lobe for sun highlights
//  • blue‑noise temporal jitter to reduce shimmer
// ────────────────────────────────────────────────────────────────────────────────

// ── varyings from the vertex stage ------------------------------------------------
varying vec2 texcoord;          // primary UVs (passthrough in vsh)
varying vec3 viewDir;           // view vector in eye space (set in vsh)

// ── built‑in OptiFine samplers ----------------------------------------------------
uniform sampler2D colortex0;    // the rendered scene (for SSR)
uniform sampler2D depthtex0;    // linear depth (0 – 1)
uniform sampler2D noisetex;     // 512×512 blue‑noise atlas

// ── extra global uniforms (OptiFine/LabPBR already provides these) ---------------
uniform vec3  sunDir;           // unit vector TO the sun, in view space
uniform vec3  sunColor;         // sunlight colour (pre‑scaled)
uniform float frameTimeCounter; // running time in seconds

// ── tweakables --------------------------------------------------------------------
const vec3  WATER_ALBEDO     = vec3(0.02, 0.25, 0.45);  // deep‑sea tint
const float WAVE_SCALE       = 0.015;   // bump strength
const float WAVE_SPEED       = 0.75;    // waves per second
const float FRESNEL_POWER    = 5.0;     // higher = glassier edges
const float SPECULAR_EXP     = 40.0;    // sun gloss (Blinn‑Phong)
const float SSR_STRENGTH     = 0.65;    // 0 = disable screenspace refl.
const float NOISE_UV_SCALE   = 1024.0;  // tile blue‑noise

// ── helper: blue‑noise based random [0,1) ----------------------------------------
float blueNoise(in vec2 p)
{
    ivec2 ip = ivec2(mod(p, 512.0));
    return texelFetch2D(noisetex, ip, 0).a;
}

// ── helper: generate procedural normal from two sine waves -----------------------
vec3 waterNormal(in vec2 uv, in float t)
{
    float w1 = sin(uv.x * 90.0 + t * WAVE_SPEED*6.0) * 0.5;
    float w2 = cos(uv.y * 75.0 + t * WAVE_SPEED*4.0);
    vec2 grad = vec2(dFdx(w1 + w2), dFdy(w1 + w2));
    return normalize(vec3(-grad * WAVE_SCALE, 1.0));
}

// ── helper: tiny Schlick Fresnel --------------------------------------------------
float fresnelTerm(in float NdV)
{
    float f = clamp(1.0 - NdV, 0.0, 1.0);
    return pow(f, FRESNEL_POWER);
}

// ── helper: cheap one‑step SSR ----------------------------------------------------
vec3 screenSpaceReflection(vec2 uv, vec3 refl)
{
    // jitter ray step length with blue‑noise to hide marching rings
    float j = blueNoise(gl_FragCoord.xy + frameTimeCounter * 123.0);
    vec2 stepUV = refl.xy * 0.02 + (j - 0.5) * 0.002;

    // march 30 steps max
    for (int i = 0; i < 30; ++i)
    {
        uv += stepUV;
        if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) break;

        float sceneZ = texture2D(depthtex0, uv).r;
        if (sceneZ < gl_FragCoord.z - 0.0005)        // hit
            return texture2D(colortex0, uv).rgb;
    }
    return vec3(0.0);
}

// ────────────────────────────────────────────────────────────────────────────────
//  MAIN
// ────────────────────────────────────────────────────────────────────────────────
void main()
{
    float t = frameTimeCounter;

    // 1. compute procedural normal and Fresnel
    vec3  N   = waterNormal(texcoord * 4.0, t);
    vec3  V   = normalize(-viewDir);          // view direction (eye → fragment)
    float NdV = max(dot(N, V), 0.0);
    float F   = fresnelTerm(NdV);

    // 2. base water colour (with a pinch of depth darkening)
    float depth = texture2D(depthtex0, texcoord).r;   // 0 near, 1 far
    vec3  waterCol = WATER_ALBEDO * mix(1.5, 0.4, depth);

    // 3. screen‑space reflection
    vec3 reflCol = screenSpaceReflection(texcoord, reflect(-V, N));
    waterCol = mix(waterCol, reflCol, F * SSR_STRENGTH);

    // 4. sun specular (simple Blinn‑Phong)
    vec3  H  = normalize(V + sunDir);
    float spec = pow(max(dot(N, H), 0.0), SPECULAR_EXP) * F;
    waterCol += sunColor * spec;

    // 5. temporal blue‑noise dithering (fade shimmer)
    float n = blueNoise(gl_FragCoord.xy * NOISE_UV_SCALE);
    waterCol += n / 255.0;

    gl_FragColor = vec4(waterCol, 1.0);
}