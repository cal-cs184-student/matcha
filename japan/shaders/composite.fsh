#version 330 compatibility 

uniform sampler2D colortex0;
uniform vec2 resolution;

in vec2 texcoord;
out vec4 fragColor;

void main() {
    vec2 uv = texcoord; // already normalized [0.0, 1.0]

    // Use texel size based on resolution to avoid oversampling
    vec2 texelSize = 1.0 / resolution;

    vec4 color = vec4(0.0);
    float totalWeight = 0.0;

    // 3x3 blur kernel with Gaussian-like weights (sharper center)
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(x, y) * texelSize;
            float weight = exp(-(x*x + y*y) / 2.0);  // Weighing samples (center heavier)

            color += texture(colortex0, uv + offset) * weight;
            totalWeight += weight;  // Keep track of total weight
        }
    }

    color /= totalWeight;  // Normalize to avoid over-brightening

    // Optional: simulate watercolor glow by soft gamma boost
    color.rgb = pow(color.rgb, vec3(0.9));

    fragColor = color;
}

