#version 330 compatibility

uniform sampler2D colortex0;
uniform sampler2D texture;
uniform vec2 texel_size;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
    vec3 color_bleed = vec3(0.0);
    float gaussian_weights[9] = float[](1.0, 2.0, 1.0, 2.0, 4.0, 2.0, 1.0, 2.0, 1.0);
    float total = 0.0;
    int idx = 0;

    for (int y = -1; y <= 1; y++) {
        for (int x = -1; x <= 1; x++) {
            vec2 offset = vec2(x, y) * texel_size * 2; 
            color_bleed += texture(colortex0, texcoord + offset).rgb * gaussian_weights[idx];
            total += gaussian_weights[idx];
            idx++;
        }
    }
    color_bleed /= total;

    color = vec4(color_bleed, 1.0);
}