#version 330 compatibility
// feeds world‑space position & normal to fragment

// outputs for the fragment stage
out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

out vec3 worldNormal;    // unit‑length, world‑space
out vec3 worldPos;       // world‑space position

// OptiFine / Minecraft uniforms
uniform mat4 gbuffer_model_view;          // world → view
uniform mat4 gbuffer_projection;          // view  → clip
uniform mat3 normal;                      // world‑space normal matrix

// fixed‑function attributes (compat profile)
in vec4 gl_Vertex;
in vec3 gl_Normal;

// main
void main()
{
    /* 1. transform vertex to clip space for rasterisation */
    vec4 viewPos = gbuffer_model_view * gl_Vertex;
    gl_Position  = gbuffer_projection * viewPos;

    /* 2. pass world‑space attributes to the fragment shader
          Note: gl_Vertex is already in *world* space inside OptiFine’s
          gbuffers pipeline (block translations are baked in).             */
    worldPos    = gl_Vertex.xyz;
    worldNormal = normalize(normal * gl_Normal);

    /* 3. vanilla UV & light‑map coords + per‑vertex tint                  */
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor  = gl_Color;
}
