#version 120
varying vec2 texcoord;
varying vec3 viewDir;
void main() {
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.xy;
    viewDir  = -(gl_ModelViewMatrix * gl_Vertex).xyz; // eye-space
}
