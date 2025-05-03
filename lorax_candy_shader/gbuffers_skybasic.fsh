#version 120
//
// Candy-Sky BASIC  - single-hue gradient, clouds, and animated pink twinkles
//

uniform int   worldTime;   // 0-23999 (MC daytime cycle)
uniform float viewWidth;
uniform float viewHeight;

/* ───────────────── hash + 2-D value-noise ───────────────────────────── */
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p)
{
    vec2 i = floor(p), f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i),
                   hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)),
                   hash(i + vec2(1.0, 1.0)), u.x), u.y);
}
/* ────────────────────────────────────────────────────────────────────── */

void main()
{
    /* -------- vertical gradient (night‑to‑day) ----------------------- */
    float v = clamp(gl_FragCoord.y / viewHeight, 0.0, 1.0);

    float t       = float(worldTime);
    float dayFrac = (cos((t - 6000.0) * 3.14159265 / 12000.0) + 1.0) * 0.5;

    const vec3 nightH = vec3(0.60, 0.00, 0.45);   // horizon at night
    const vec3 nightZ = vec3(0.25, 0.00, 0.35);   // zenith  at night

    vec3 dayH = mix(nightH, vec3(1.0), 0.65);     // lighter sunrise hue
    vec3 dayZ = mix(nightZ, vec3(1.0), 0.55);     // lighter zenith

    vec3 horizonCol = mix(nightH, dayH, dayFrac);
    vec3 zenithCol  = mix(nightZ, dayZ, dayFrac);
    vec3 skyCol     = mix(horizonCol, zenithCol, v);

    /* -------------------- soft clouds -------------------------------- */
    vec2 cloudUV    = gl_FragCoord.xy * 0.0015 + vec2(t * 0.00003, 0.0);
    float cloudN    = noise(cloudUV) * noise(cloudUV * 2.0);
    float cloudMask = smoothstep(0.45, 0.65, cloudN);

    vec3 cloudDay   = vec3(0.65, 0.95, 0.95);
    vec3 cloudNight = vec3(0.15, 0.25, 0.45);
    vec3 cloudCol   = mix(cloudNight, cloudDay, dayFrac);

    skyCol = mix(skyCol, cloudCol, cloudMask * 0.6);

    /* -------------------- starfield ---------------------------------- */
    float starPhase = max(0.0, (0.6 - dayFrac) / 0.6);   // 0 = daylight, 1 = full night
    if (starPhase > 0.0)
    {
        /* jitter star grid a tiny amount each frame so pixels don't align */
        vec2 starUV = (gl_FragCoord.xy + vec2(
                         37.0 * sin(t * 0.023),          // small wobble X
                         29.0 * cos(t * 0.017))) * 0.007;

        vec2 cell = floor(starUV);
        float h   = hash(cell);

        /* ---- small twinkling stars ---------------------------------- */
        if (h > 0.982)                                   // ~1.8% of cells
        {
            float tw = 0.5 + 0.5 *
                       sin(t * 0.5 + h * 17.0 +
                           sin(t * 1.3 + h * 53.0) * 1.4);

            float dist = length(fract(starUV) - 0.5);
            float halo = smoothstep(0.35, 0.0, dist);

            vec3 starCol = vec3(1.0, 0.78, 0.92);        // pastel pink
            skyCol = mix(skyCol, starCol, halo * tw * starPhase);
        }

        /* ---- bright flare stars with cross -------------------------- */
        if (h > 0.9975)                                  // ~0.25% of cells
        {
            vec2 f  = fract(starUV) - 0.5;
            float r = length(f);

            float halo  = smoothstep(0.48, 0.0, r);
            float cross = (smoothstep(0.38, 0.0, abs(f.x)) +
                           smoothstep(0.38, 0.0, abs(f.y))) * 0.5;

            float tw = 0.35 + 0.65 *
                       sin(t * 0.18 + h * 200.0 +
                           sin(t * 0.8 + h * 91.0) * 2.1);

            vec3 flareCol = vec3(1.0, 0.78, 0.95);
            float intensity = (halo + cross) * tw * starPhase;
            skyCol = mix(skyCol, flareCol, intensity);
        }
    }

    gl_FragColor = vec4(skyCol, 1.0);
}
