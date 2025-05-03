#version 120
// gbuffers_water.fsh – solid pink refraction + pink‑tinted reflections

varying vec2 texcoord;
varying vec3 viewDir;

/* ── OptiFine / vanilla samplers ───────────────────────────────────── */
uniform sampler2D colortex0;        // full scene (for SSR)
uniform sampler2D depthtex0;        // linear depth
uniform sampler2D noisetex;         // blue‑noise
uniform vec3     sunDir;            // view‑space sun direction
uniform vec3     sunColor;          // white unless a shader pack changes it
uniform float    frameTimeCounter;

/* ── constants – tweak here to change hue/strength ─────────────────── */
const vec3  PINK_BASE  = vec3(1.00, 0.35, 0.70);  // flat refraction tint
const vec3  PINK_REF   = vec3(1.00, 0.45, 0.80);  // reflection tint
const vec3  PINK_SPEC  = vec3(1.00, 0.45, 0.80);  // specular colour

const float WAVE_SCALE = 0.015;
const float WAVE_SPEED = 0.75;
const float FRESNEL_P  = 5.0;
const float SPEC_EXP   = 40.0;
const float SSR_STR    = 0.65;

/* ── helpers — unchanged maths from your original —──────────────────── */
float blueNoise(vec2 p){
    ivec2 ip = ivec2(mod(p,512.0));
    return texelFetch2D(noisetex,ip,0).a;
}
vec3 waterNormal(vec2 uv,float t){
    float w1=sin(uv.x*90.0+t*WAVE_SPEED*6.0)*0.5;
    float w2=cos(uv.y*75.0+t*WAVE_SPEED*4.0);
    vec2 g = vec2(dFdx(w1+w2), dFdy(w1+w2));
    return normalize(vec3(-g*WAVE_SCALE,1.0));
}
float fresnel(float NdV){ return pow(clamp(1.0-NdV,0.0,1.0),FRESNEL_P); }
vec3 SSR(vec2 uv,vec3 refl){
    float j=blueNoise(gl_FragCoord.xy+frameTimeCounter*123.0);
    vec2 step=refl.xy*0.02+(j-0.5)*0.002;
    for(int i=0;i<30;i++){
        uv+=step;
        if(uv.x<0.0||uv.x>1.0||uv.y<0.0||uv.y>1.0) break;
        if(texture2D(depthtex0,uv).r < gl_FragCoord.z-0.0005)
            return texture2D(colortex0,uv).rgb;
    }
    return vec3(0.0);
}

/* ── MAIN ───────────────────────────────────────────────────────────── */
void main(){
    float t=frameTimeCounter;

    vec3 N  = waterNormal(texcoord*4.0,t);
    vec3 V  = normalize(-viewDir);
    float F = fresnel(max(dot(N,V),0.0));

    /* 1. solid pink base (no depth modulation) */
    vec3 waterCol = PINK_BASE;

    /* 2. screen‑space reflection → tint pink */
    vec3 refl = SSR(texcoord, reflect(-V,N)) * PINK_REF;
    waterCol  = mix(waterCol, refl, F*SSR_STR);

    /* 3. pink specular sparkle */
    vec3  H = normalize(V + sunDir);
    float s = pow(max(dot(N,H),0.0), SPEC_EXP) * F;
    waterCol += PINK_SPEC * s;

    /* 4. micro‑shimmer */
    waterCol += blueNoise(gl_FragCoord.xy*1024.0)/255.0;

    gl_FragColor = vec4(waterCol,1.0);
}
