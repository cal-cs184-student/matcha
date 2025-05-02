#version 330 compatibility

out vec2 lmcoord;
out vec2 texcoord;
out vec4 glcolor;

uniform mat4 gl_ModelViewProjectionMatrix;
uniform float frameTimeCounter;

in vec4 gl_Vertex;
in vec3 gl_Normal;

void main() {
    // sin curve based swaying motion scaled by time and world position
    float windStrength = 1.0;
    float sway = sin(frameTimeCounter + gl_Vertex.x * 0.2 + gl_Vertex.z * 0.2)
               * windStrength;

    float isLeaf = clamp((gl_Color.g - gl_Color.r - gl_Color.b) * 2.0, 0.0, 1.0); // greener = more likely a leaf
    vec3 displacement = isLeaf * vec3(
        sway * 0.3,  // in x dir
        sway * 0.1, // y
        sway * 0.3   // z
    );

    gl_Position = gl_ModelViewProjectionMatrix * (gl_Vertex + vec4(displacement, 0.0));

    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor  = gl_Color;
}
