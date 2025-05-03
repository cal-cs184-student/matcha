#version 120
// ---------------------------------------------------------------------------
//  Candyland composite  ✧  bright pastel lighting & fog
// ---------------------------------------------------------------------------

varying vec2 TexCoords;

uniform sampler2D colortex0;   // albedo (sRGB)
uniform sampler2D colortex1;   // normal (RGB packed)
uniform sampler2D colortex2;   // light-map coords
uniform sampler2D depthtex0;

uniform int   worldTime;
uniform float near;
uniform float far;

/* DRAWBUFFERS:0 */

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
vec3 toLinear (vec3 c) { return pow(c, vec3(2.2)); }
vec3 toSRGB   (vec3 c) { return pow(c, vec3(1.0/2.2)); }

// simple pastel-LUT fudge – pulls tones gently to pink / lavender
vec3 pastelLUT(vec3 c)
{
    // bias hue towards pink (raise R & B a touch, lower G a touch)
    return clamp(vec3(c.r*1.04 + 0.03,
                      c.g*0.96 - 0.02,
                      c.b*1.06 + 0.04), 0.0, 1.0);
}

// convert depth to linear eye-space Z
float linearDepth(float ndc)
{
    float z = ndc*2.0 - 1.0;
    return 2.0*near*far / (far + near - z*(far-near));
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
void main()
{
    // -----------------------------------------------------------------------
    //  Inputs
    // -----------------------------------------------------------------------
    vec3  albedoSRGB  = texture2D(colortex0, TexCoords).rgb;
    vec3  albedo      = toLinear(albedoSRGB);                 // linear space
    vec3  normal      = normalize(texture2D(colortex1, TexCoords).rgb*2.0-1.0);
    vec2  lmUV        = texture2D(colortex2, TexCoords).rg;
    float depthNDC    = texture2D(depthtex0, TexCoords).r;

    // sky pixel?  show pink sky as-is and quit
    if (depthNDC >= 0.999) { gl_FragData[0]=vec4(albedoSRGB,1.0); return; }

    // -----------------------------------------------------------------------
    //  Time-of-day factors
    // -----------------------------------------------------------------------
    float angle = float(worldTime)/24000.0 * 6.28318;          // 0 – 2π
    float dayL  = (cos(angle-3.14159)+1.0)*0.5;                // 0 night →1 day

    // brighter pastel palettes
    vec3 dayH   = vec3(1.04,0.94,1.05);   // horizon tint by day
    vec3 nightH = vec3(0.85,0.80,1.00);   // horizon tint by night
    vec3 ambientColor = mix(nightH, dayH, dayL);

    // -----------------------------------------------------------------------
    //  Decode / tweak lightmap  (simple pastel bias)
    // -----------------------------------------------------------------------
    float blockL = max(lmUV.x, 0.50);  // enforce lighter minimum
    float skyL   = max(lmUV.y, 0.70);

    // base ambient term – quite high so shadows never crush
    vec3 lighting = ambientColor * (0.55*blockL + 0.65*skyL);

    // a soft directional boost (sun / moon)
    vec3 sunDir   = normalize(vec3(0.15, 1.0, 0.25));
    float diffuse = max(dot(normal,sunDir), 0.0);
    lighting     += ambientColor * diffuse * 0.6;

    // -----------------------------------------------------------------------
    //  Compose
    // -----------------------------------------------------------------------
    vec3 litLinear = albedo * lighting;

    // apply gentle LUT for extra pastel pop
    vec3 litSRGB   = toSRGB(litLinear);
    litSRGB        = mix(litSRGB, pastelLUT(litSRGB), 0.35); // 35 % pastel bias

    gl_FragData[0] = vec4(finalColor,1.0);
}
