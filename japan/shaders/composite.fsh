#version 330 compatibility

uniform sampler2D colortex0;
uniform vec2 resolution;

varying vec2 texcoord;

void main() {
    vec2 texelSize = 1.0 / resolution;
    vec4 centerColor = texture2D(colortex0, texcoord);
    
    vec4 finalColor = vec4(0.0);
    float totalWeight = 0.0;

    const float sigma_spatial = 2.0; // how big blur is
    const float sigma_color = 0.1;   // lower = more edges

    for (int x = -2; x <= 2; ++x) {
        for (int y = -2; y <= 2; ++y) {
            vec2 offset = vec2(x, y) * texelSize;
            vec2 sampleUV = texcoord + offset;

            vec4 sampleColor = texture2D(colortex0, sampleUV);

            float spatialWeight = exp(-(x*x + y*y) / (2.0 * sigma_spatial * sigma_spatial));
            float colorDiff = length(sampleColor.rgb - centerColor.rgb);
            float colorWeight = exp(-(colorDiff * colorDiff) / (2.0 * sigma_color * sigma_color));

            float weight = spatialWeight * colorWeight;

            finalColor += sampleColor * weight;
            totalWeight += weight;
        }
    }

    finalColor /= totalWeight;
    finalColor.rgb = pow(finalColor.rgb, vec3(0.9)); // tone adjustment (optional)

    gl_FragColor = finalColor;
}
