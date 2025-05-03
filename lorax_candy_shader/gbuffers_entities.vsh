#version 120
// passes UV, vertex colour, light-map UV, normal

varying vec2 texcoord;      // block atlas UV
varying vec4 vColor;        // biome/ao tint colour
varying vec2 lmcoord;       // light-map UV
varying vec3 vNormal;       // view-space normal for lighting

void main()
{
    gl_Position = ftransform();

    texcoord = gl_MultiTexCoord0.st;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).st; // pass raw to fsh
    vColor   = gl_Color;                                     // biome tint
    vNormal  = normalize(gl_NormalMatrix * gl_Normal);       // to view-space
}
