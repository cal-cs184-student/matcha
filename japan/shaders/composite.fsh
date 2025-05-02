#version 330 core

// Uniforms provided by the shader pipeline
uniform sampler2D colortex0;      // The screen image
uniform sampler2D noiseTexture;   // Optional watercolor paper grain
uniform vec2 resolution;          // Screen resolution (in pixels)

in vec2 texCoord;                 // Provided UV coordinates
out vec4 fragColor;               // Final pixel color

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;

    // Watercolor-style blur kernel
    vec4 color = vec4(0.0);
    float offset = 1.0 / 720.0; // change based on resolution

    // 5x5 Gaussian-like blur (soft watercolor blend)
    for (int x = -2; x <= 2; ++x) {
        for (int y = -2; y <= 2; ++y) {
            vec2 sampleUV = uv + vec2(x, y) * offset;
            color += texture(colortex0, sampleUV);
        }
    }
    color /= 25.0;

    // Optional: boost midtones for soft glow
    color.rgb = pow(color.rgb, vec3(0.9));

    fragColor = color;
}
