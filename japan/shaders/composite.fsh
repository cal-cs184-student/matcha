#version 330 compatibility

uniform sampler2D colortex0;
uniform vec2 resolution;

varying vec2 texcoord;   //receive texture coordinates from the vertex shader
void main() {
    vec2 uv = texcoord;  //alr normalized [0.0, 1.0]

    vec2 texelSize = 1.0 / resolution;

    vec4 color = vec4(0.0);
    float totalWeight = 0.0;

    //5x5 Gaussian-like blur with center-heavy weights
    for (int x = -2; x <= 2; ++x) {
        for (int y = -2; y <= 2; ++y) {
            vec2 offset = vec2(x, y) * texelSize * 1.1; // 1.5 = blur strength factor

            float weight = exp(-(x*x + y*y) / 2.0); //tune denominator for blur softness

            color += texture2D(colortex0, uv + offset) * weight;  //use 'texture2D' for compatibility mode
            totalWeight += weight;
        }
    }

    color /= totalWeight;
    color.rgb = pow(color.rgb, vec3(0.9));
    gl_FragColor = color;
}