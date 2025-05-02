#version 330 compatibility
// baked lightmap + planar reflection with Fresnel

// samplers
uniform sampler2D lightmap;              // MC light‑map
uniform sampler2D gtexture;              // base albedo / water texture
uniform sampler2D fake_reflection_color; // blurred scene capture

// uniforms
uniform vec3  cameraPos;
uniform float alphaTestRef = 0.10;

// varyings from vertex shader
in vec2 texcoord;
in vec2 lmcoord;
in vec4 glcolor;

in vec3 worldNormal;   // already unit‑length (see vsh)
in vec3 worldPos;

// output
layout(location = 0) out vec4 outColor;

// helper : Schlick Fresnel (cheap)
float fresnelSchlick(float cosTheta, float f0)
{
    return f0 + (1.0 - f0) * pow(clamp(1.0 - cosTheta, 0.0, 1.0), 5.0);
}

void main()
{
    /* 1.  sample base colour & lighting exactly like vanilla */
    vec4 baseCol = texture(gtexture, texcoord) * glcolor;
    baseCol     *= texture(lightmap, lmcoord);

    /* 2.  alpha‑clip before any heavy work */
    if (baseCol.a < alphaTestRef) discard;

    /* 3.  view & surface vectors (world‑space) */
    vec3 N = normalize(worldNormal);
    vec3 V = normalize(cameraPos - worldPos);
    vec3 R = reflect(-V, N);

    /* 4.  planar reflection lookup
           – smaller scale so tiles don’t fold on themselves
           – fract() wraps into [0,1) avoiding bleed‑edges            */
    vec2 reflUV = fract(texcoord + R.xy * 0.06);

    vec3 reflCol = texture(fake_reflection_color, reflUV).rgb;

    /* 5.  Fresnel weighting : at grazing angles → 1, facing → ~0.05   */
    float f0   = 0.05;                                 // base reflectivity
    float fres = fresnelSchlick(max(dot(N, V), 0.0), f0);

    /* 6.  final mix (RGB only – keep alpha intact) */
    outColor.rgb = mix(baseCol.rgb, reflCol, fres * 0.65); // 0.65 = strength
    outColor.a   = baseCol.a;                              // preserve cut‑out
}
