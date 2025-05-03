#version 120
//------------------------------------------------------------------
// Candy-pink foliage fragment stage
//------------------------------------------------------------------
varying vec2 texcoord;
varying vec4 vColor;
varying vec2 lmcoord;
varying vec3 vNormal;

uniform sampler2D texture;

/* DRAWBUFFERS:012 */

// helpers
bool isWhiteish(vec3 c)  { return (c.r + c.g + c.b) > 2.8; }
bool isFoliage (vec3 c)  { return (c.g > 0.35) && (c.g > c.r + 0.05) && (c.g > c.b + 0.05); }

void main()
{
    vec4 tex = texture2D(texture, texcoord);

    vec4 albedo;
    if (isWhiteish(tex.rgb))                       // snowy / candy blocks
        albedo = tex;
    else if (isFoliage(tex.rgb)) {                 // grass, leaves, vines …
        const vec3 pink = vec3(1.00, 0.75, 0.90);
        vec3  mixed     = mix(tex.rgb, pink, 0.80);          // 80 % pink
        vec3  withTint  = mix(mixed, mixed * vColor.rgb, 0.25); // keep 25 % biome shade
        albedo          = vec4(withTint, tex.a);
    } else
        albedo = tex * vColor;                     // vanilla for everything else

    if (albedo.a < 0.10) discard;                  // cut-out mask

    // write G-buffer
    gl_FragData[0] = albedo;                       // colortex0  (sRGB albedo)
    gl_FragData[1] = vec4(vNormal * 0.5 + 0.5, 1.0); // colortex1  encoded normal
    gl_FragData[2] = vec4(lmcoord * 33.05/32.0      // colortex2  light-map UV
                          - 1.05/32.0, 0.0, 1.0);
}
