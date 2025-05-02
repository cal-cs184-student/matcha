#version 330 core

uniform sampler2D colortex0;
uniform vec2 resolution;

in vec2 texCoord;
out vec4 fragColor;

void main() {
    vec2 uv = texCoord; // already normalized [0.0, 1.0]

    // Use texel size based on resolution to avoid oversampling
    vec2 texelSize = 1.0 / resolution;

    vec4 color = vec4(0.0);
    float weight = 1.0;

    // 3x3 blur kernel — softer, less destructive than 5x5
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(x, y) * texelSize;
            color += texture(colortex0, uv + offset) * weight;
        }
    }

    color /= 9.0;

    // Optional: simulate watercolor glow by soft gamma boost
    color.rgb = pow(color.rgb, vec3(0.9));

    fragColor = color;
}
