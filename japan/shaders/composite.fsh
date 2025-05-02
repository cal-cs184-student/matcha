#version 330 compatibility	

uniform sampler2D colortex0; 
uniform sampler2D noiseTexture; 
uniform vec2 resolution; 

in vec2 texCoord; 
out vec4 fragColor; 

void main() {
    vec2 uv = gl_FragCoord.xy / resolution.xy;

    vec4 color = vec4(0.0);
    float offset = 1.0 / 720.0;

    // 5x5 Gaussian-like blur (soft watercolor blend)
    for (int x = -2; x <= 2; ++x) {
        for (int y = -2; y <= 2; ++y) {
            vec2 sampleUV = uv + vec2(x, y) * offset;
            color += texture(colortex0, sampleUV);
        }
    }
    color /= 25.0;

    vec4 noise = texture(noiseTexture, uv * 4.0);  // Tiling factor 4.0
    color.rgb = mix(color.rgb, noise.rgb, 0.05);   // Subtle paper effect

    color.rgb = pow(color.rgb, vec3(0.9));

    fragColor = color;
}