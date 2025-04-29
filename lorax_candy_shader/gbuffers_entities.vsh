#version 120

varying vec2 texcoord;
varying vec4 vertexColor;
varying vec3 normal;

void main() {
    gl_Position = ftransform();
    texcoord = gl_MultiTexCoord0.st;
    vertexColor = gl_Color;
    normal = normalize(gl_NormalMatrix * gl_Normal);
}